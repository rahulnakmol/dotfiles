# zsh

Zsh shell configuration with modular sourcing, multi-distro package manager aliases, and plugin management.

## Key Files

| File | Purpose |
|------|---------|
| `.zshrc` | Main entrypoint: PATH setup, Homebrew detection, modular sourcing, plugin loading |
| `.zprofile` | Login-shell env vars: GOPATH, CARGO_HOME, RUSTUP_HOME, BAT_THEME, MANPAGER |
| `.zshrc.d/00-distro.zsh` | Detects distro via `/etc/os-release`, exports `DOTFILES_DISTRO` |
| `.zshrc.d/aliases.zsh` | All shell aliases (git, gh, tmux, npm, docker, claude, opencode, azure, ssh, etc.) |
| `.zshrc.d/pkg-ubuntu.zsh` | `apt` + `brew` aliases, guarded by `DOTFILES_DISTRO == ubuntu` |
| `.zshrc.d/pkg-fedora.zsh` | `dnf` aliases, guarded by `DOTFILES_DISTRO == fedora` |
| `.zshrc.d/pkg-opensuse.zsh` | `zypper` aliases, guarded by `DOTFILES_DISTRO == opensuse` |
| `.zshrc.d/catppuccin-fzf-macchiato.sh` | Catppuccin Macchiato color scheme for fzf |
| `.hushlogin` | Suppresses login banner |

## Modular Sourcing

`.zshrc` sources all `*.zsh` and `*.sh` files from `~/.zshrc.d/` in sorted order. The `00-distro.zsh` file runs first and sets `DOTFILES_DISTRO`, which the `pkg-*.zsh` files use as a guard (`return 0` if wrong distro).

## Multi-Distro Support

| Distro Family | Variable Value | Package Aliases |
|---------------|----------------|-----------------|
| Ubuntu/Debian/Pop/Mint | `ubuntu` | `ai`, `au`, `aup`, `aug` + brew (`bi`, `bu`, etc.) |
| Fedora/RHEL/CentOS/Rocky | `fedora` | `dni`, `dnu`, `dnup`, `dnug` |
| openSUSE/SLES | `opensuse` | `zyi`, `zyu`, `zyup`, `zyug`, `zydup` |

## Shell Integrations

| Tool | Init Method |
|------|-------------|
| Starship | `eval "$(starship init zsh)"` |
| Zoxide | `eval "$(zoxide init --cmd cd zsh)"` |
| fzf | Cached to `~/.cache/fzf-zsh.zsh` for faster startup |

## Plugins

Loaded from Homebrew `share/` or system `/usr/share/`:

- `zsh-autocomplete` — asynchronous type-ahead completion and completion UI
- `zsh-autosuggestions` — history-based inline suggestions
- `zsh-syntax-highlighting` — command validity and shell syntax coloring
- `zsh-completions` — additional command-specific completion definitions

Load order is intentional: Autocomplete initializes completion before custom widgets, Autosuggestions
loads afterward, and Syntax Highlighting loads last so it observes every line-editor hook.

On shared Homebrew installations, run:

```bash
~/.dotfiles/scripts/sync-zsh-completions.zsh
```

This copies completion definitions and plugin code into user-owned directories, then rebuilds the
completion dump. Homebrew remains the version source, while Zsh executes private synchronized copies
that satisfy `compaudit` instead of trusting a third-user-owned shared completion tree.

## Notable Alias Groups

- **Claude Code**: `cc`, `ccs` (sonnet), `cco` (opus), `cch` (haiku), `ccpl` (plan), `cc!`/`cco!` (autopilot)
- **OpenCode**: `oc`, `occ`, `ocr`, `ocm`, `ocum` (update models), `ocumd` (dry-run)
- **Containers**: `docker` aliased to `podman`; full compose support via `dc`, `dcu`, `dcd`
- **Navigation**: `eza` replaces `ls`; `bat` replaces `cat`; `zoxide` replaces `cd`

## Dependencies

Homebrew (Linux), starship, zoxide, fzf, eza, bat, and the four focused Zsh extensions above.

## Local Overrides

`~/.zshrc.local` is sourced last if present (not committed).
