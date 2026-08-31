# WSL Setup

WSL2 is a first-class platform in this repo, not an afterthought — but a handful of things behave
differently from native Linux because two OSes are involved. This page covers all of them.

## Prerequisites

- WSL2 (not WSL1 — `wsl --set-default-version 2`, then check with `wsl -l -v`)
- A distro this repo already supports (Ubuntu, Fedora, or openSUSE) installed inside WSL
- [WezTerm](https://wezfurlong.org/wezterm/) on the **Windows** side — Ghostty has no Windows build
- 1Password for Windows, if you want SSH/signing to go through it rather than a local key

Everything else in [dependencies.md](dependencies.md) applies the same as native Linux; install it
*inside* the WSL distro, not on Windows.

## What's WSL-specific

`00-platform.zsh` exports `$DOTFILES_WSL` as `1` or `2` (never a bare boolean — WSL1 has no
`$WSL_INTEROP` and different `/mnt` filesystem behavior, so code that only checks true/false gets
it wrong), plus `$DOTFILES_WIN_USER`/`$DOTFILES_WIN_HOME` resolved via `cmd.exe` and cached to
`~/.cache/dotfiles-winuser` — not by listing `/mnt/c/Users` and taking the first entry, which
returns whatever sorts alphabetically first (often `Administrator` or `Default`), not you.

`10-wsl.zsh` and `zz-wsl-aliases.zsh` (self-guarding, load only under WSL):

- **Clipboard** — `pbcopy`/`pbpaste` over `clip.exe` / PowerShell's `Get-Clipboard`
- **1Password bridge** — see below
- **Interop** — `open`/`explore` → `explorer.exe .`, `winhome`, `wpath`/`lpath` → `wslpath -w`/`-u`
- **`prj`/`ghr`** overridden to the Windows filesystem, where project files commonly live for
  tooling/performance reasons — this is why the alias file is named `zz-wsl-aliases.zsh` rather
  than numbered: digits sort *before* letters, so a numeric prefix would load before `aliases.zsh`
  and lose the override
- **Windows PATH pruning** — off by default (`clip.exe`/`npiperelay.exe`/1Password's Windows
  signer all need Windows `PATH` entries); opt in with `DOTFILES_WSL_PRUNE_PATH=1` in
  `~/.zshrc.local` to filter `/mnt/c/*` down to an allowlist

## 1Password SSH agent bridge

1Password on Windows exposes its agent as a named pipe, not a Unix socket. `10-wsl.zsh` bridges it
with [`npiperelay`](https://github.com/jstarks/npiperelay) + `socat`:

```bash
socat UNIX-LISTEN:~/.1password/agent.sock,fork \
  EXEC:"npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork
```

The dotfiles shell starts this automatically once both binaries are on `PATH` and the socket
doesn't already exist — install `socat` inside WSL and `npiperelay.exe` somewhere Windows `PATH`
reaches, and it just works. `ssh/.ssh/config` only claims `~/.1password/agent.sock` when it's
actually a live socket (`Match host * exec "test -S %d/.1password/agent.sock"`), so SSH keeps
working with a plain local key if the bridge isn't set up.

## Commit signing on WSL

Nothing WSL-specific is needed here — that's the point. The committed git config never hardcodes a
1Password path; it always refuses to commit until `scripts/setup-signing-key.sh` has run on that
machine. On WSL, that's usually:

```bash
# Either point at 1Password's Windows signer (auto-located under
# /mnt/c/Users/<you>/AppData/Local/1Password/app/*/):
./scripts/setup-signing-key.sh --1password

# Or generate a signing-only key that lives entirely inside WSL:
./scripts/setup-signing-key.sh --local
```

See [git.md](../modules/git.md) for how the three modes work.

## Terminal: WezTerm, not Ghostty

Ghostty doesn't ship a Windows build, so `wezterm` is a separate module deployed *inside* WSL and
then symlinked to where Windows actually looks for it:

```bash
stow wezterm
cmd.exe /c mklink /D "%USERPROFILE%\.config\wezterm" "\\wsl$\<distro>\home\<user>\.config\wezterm"
```

Details in [docs/modules/wezterm.md](../modules/wezterm.md).

## Migrating an existing WSL (or any) machine after the `00-distro.zsh` rename

`00-distro.zsh` was renamed to `00-platform.zsh`. A machine stowed before that rename has a stale
`~/.zshrc.d/00-distro.zsh` symlink pointing at a file that no longer exists in the repo — stow
won't clean that up on its own:

```bash
cd ~/.dotfiles
stow -D zsh
stow zsh
```

## Filesystem performance

Keep the repo (and your projects generally) inside the WSL filesystem (`~/...`), never under
`/mnt/c/...`. Cross-filesystem access from WSL to `/mnt/c` is dramatically slower than native
WSL-side I/O — this matters for git status, LazyVim's file watching, and tmux's pane responsiveness
alike.
