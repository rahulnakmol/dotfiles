# dotfiles

Linux dotfiles themed around **Catppuccin Macchiato**. Each top-level directory is a [GNU Stow](https://www.gnu.org/software/stow/) module that symlinks into `$HOME`.

Multi-distro: Ubuntu/Debian, Fedora, openSUSE Tumbleweed, and **WSL2** (any distro).

## Quick start

```bash
git clone https://github.com/rahulnakmol/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

stow -n zsh        # dry-run — preview symlinks
stow zsh tmux git  # deploy selected modules
```

Re-run `stow <module>` after pulling changes to keep `$HOME` in sync.

## Prerequisites

| Category | Tools |
|----------|-------|
| Core | `git`, `stow`, `zsh`, `curl`, `jq` |
| CLI | `eza`, `bat`, `fd`, `ripgrep`, `fzf`, `zoxide` |
| Terminal | [Ghostty](https://ghostty.org) (Linux), [WezTerm](https://wezfurlong.org/wezterm/) (WSL), [tmux](https://github.com/tmux/tmux), [Starship](https://starship.rs) |
| Editor | [Neovim](https://neovim.io) 0.10+ (LazyVim) |
| Font | [Mononoki Nerd Font](https://www.nerdfonts.com) |
| Optional | [1Password](https://1password.com) (SSH agent + commit signing), [Homebrew](https://brew.sh) |

Full list with per-distro install commands: [docs/guides/dependencies.md](docs/guides/dependencies.md)

## Modules

| Module | What it configures | Docs |
|--------|--------------------|------|
| `zsh` | Modular shell with 120+ aliases, multi-distro + WSL support | [details](docs/modules/zsh.md) |
| `tmux` | `C-a` prefix, vim-style navigation, session persistence, AI tool popups | [details](docs/modules/tmux.md) |
| `nvim` | LazyVim bootstrap with Catppuccin theme | [details](docs/modules/nvim.md) |
| `starship` | Prompt with Catppuccin palette and Nerd Font glyphs | [details](docs/modules/starship.md) |
| `git` | User identity; commit signing configured per machine, on demand | [details](docs/modules/git.md) |
| `gh` | GitHub CLI, 27 workflow aliases | [details](docs/modules/gh.md) |
| `ssh` | 1Password SSH agent, claimed only when actually running | [details](docs/modules/ssh.md) |
| `ghostty` | Terminal (Linux): Catppuccin theme, Mononoki font, translucent window | [details](docs/modules/ghostty.md) |
| `wezterm` | Terminal (WSL): same theme, WSL-domain-aware AI keybindings | [details](docs/modules/wezterm.md) |
| `bat` | Catppuccin syntax-highlighting themes | [details](docs/modules/bat.md) |
| `1password` | SSH agent, security settings, compact UI | [details](docs/modules/1password.md) |
| `claude` | Settings, 41 plugins, custom statusline, CLAUDE.md + 10 path-scoped rules | [details](docs/modules/claude.md) |
| `cursor` | 14 path-scoped rules mirroring Claude's | [details](docs/modules/cursor.md) |
| `codex` | 5 profiles on the ChatGPT Pro plan, mirroring Claude/OpenCode | [details](docs/modules/codex.md) |
| `opencode` | OpenCode with pro/quick/ui agents, model auto-updater | [details](docs/modules/opencode.md) |

## Shell aliases at a glance

Aliases follow a **prefix convention** so they're predictable:

| Prefix | Domain | Examples |
|--------|--------|----------|
| `g` | Git | `gs` status, `ga` add, `gc` commit, `gp` push |
| `gh` | GitHub CLI | `gprs` list PRs, `gpc` PR create, `gsync` repo sync |
| `t` | Tmux | `ta` attach, `tl` list, `tn` new session |
| `d` | Docker/Podman | `dps` ps, `dex` exec, `dcu` compose up |
| `cc` | Claude Code | `cc` interactive, `cco` opus, `ccs` sonnet |
| `oc` | OpenCode | `oc` launch, `ocum` update models |
| `s` | SSH | `s` connect, `snew` gen key, `spub` show pubkey |
| `a` | APT (Ubuntu) | `ai` install, `as` search, `aup` upgrade |
| `dn` | DNF (Fedora) | `dni` install, `dns` search, `dnup` upgrade |
| `zy` | Zypper (openSUSE) | `zyi` install, `zys` search, `zyup` upgrade |

Full reference: [docs/guides/aliases.md](docs/guides/aliases.md)

## Tmux keybindings

Prefix is `C-a`. Pane navigation (`M-arrows`) is prefix-free.

| Key | Action |
|-----|--------|
| `C-a '` | Split horizontal |
| `C-a \` | Split vertical |
| `C-a c` → `c` | Claude Code popup |
| `C-a c` → `o` | Claude Code split (Opus) |
| `C-a o` → `o` | OpenCode popup |
| `C-a o` → `p` | OpenCode split (Opus) |

Full reference: [docs/guides/tmux-keybindings.md](docs/guides/tmux-keybindings.md)

## Multi-distro and WSL support

`zsh/.zshrc.d/00-platform.zsh` detects the running distro (`$DOTFILES_DISTRO`) and whether this
is WSL1 or WSL2 (`$DOTFILES_WSL`). Distro-specific alias files (`pkg-ubuntu.zsh`, `pkg-fedora.zsh`,
`pkg-opensuse.zsh`) and the WSL files (`10-wsl.zsh`, `11-clipboard.zsh`, `zz-wsl-aliases.zsh`)
self-guard — they return immediately on the wrong platform. See
[docs/guides/wsl.md](docs/guides/wsl.md) for the WSL-specific bridge (1Password agent, clipboard,
Windows interop) and the migration step existing machines need after the `00-distro.zsh` rename.

## Theme

Catppuccin **Macchiato** everywhere: Ghostty, WezTerm, tmux, Starship, Neovim, FZF, and bat.

## Docs

- [Dependencies](docs/guides/dependencies.md) — every tool with per-distro install commands
- [Setup guide](docs/guides/setup.md) — fresh machine walkthrough
- [WSL guide](docs/guides/wsl.md) — the 1Password bridge, clipboard, signing, Windows interop
- [Aliases cheatsheet](docs/guides/aliases.md) — every alias grouped by domain
- [Tmux keybindings](docs/guides/tmux-keybindings.md) — full key reference
- [Skills](docs/skills.md) — agent behavior, installed via `scripts/bootstrap-skills.sh`
- Per-module docs in [`docs/modules/`](docs/modules/)

## CI and security

Every push runs shell/Lua lint, a tmux smoke test, a stow dry-run of every module, the
[agent-policy](agent-policy/) validator, and a TruffleHog secret scan (`.github/workflows/ci.yml`).
`agent-policy/catalog.json` is the single source of truth for what Claude Code, Codex, Cursor, and
OpenCode may read, edit, or run — `node scripts/apply-agent-policy.mjs` regenerates all four
adapters from it.

## Contributing

See [AGENTS.md](AGENTS.md) for commit conventions, validation commands, and project structure.

## License

[Apache-2.0](LICENSE)
