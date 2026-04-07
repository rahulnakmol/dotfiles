# dotfiles

Linux dotfiles themed around **Catppuccin Macchiato**. Each top-level directory is a [GNU Stow](https://www.gnu.org/software/stow/) module that symlinks into `$HOME`.

Multi-distro: Ubuntu/Debian, Fedora, and openSUSE Tumbleweed.

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
| Core | `git`, `stow`, `zsh` |
| CLI | `eza`, `bat`, `fd`, `ripgrep`, `fzf`, `zoxide` |
| Terminal | [Ghostty](https://ghostty.org), [tmux](https://github.com/tmux/tmux), [Starship](https://starship.rs) |
| Editor | [Neovim](https://neovim.io) 0.10+ (LazyVim) |
| Font | [Mononoki Nerd Font](https://www.nerdfonts.com) |
| Optional | [1Password](https://1password.com) (SSH agent + commit signing), [Homebrew](https://brew.sh) |

Full list with per-distro install commands: [docs/guides/dependencies.md](docs/guides/dependencies.md)

## Modules

| Module | What it configures | Docs |
|--------|--------------------|------|
| `zsh` | Modular shell with 120+ aliases, multi-distro package manager support | [details](docs/modules/zsh.md) |
| `tmux` | `C-a` prefix, vim-style navigation, AI tool popup keybindings | [details](docs/modules/tmux.md) |
| `nvim` | LazyVim bootstrap with Catppuccin theme | [details](docs/modules/nvim.md) |
| `starship` | Prompt with Catppuccin palette and Nerd Font glyphs | [details](docs/modules/starship.md) |
| `git` | User identity, SSH commit signing via 1Password | [details](docs/modules/git.md) |
| `gh` | GitHub CLI defaults | [details](docs/modules/gh.md) |
| `ssh` | 1Password SSH agent on macOS and Linux | [details](docs/modules/ssh.md) |
| `ghostty` | Terminal: Catppuccin theme, Mononoki font, translucent window | [details](docs/modules/ghostty.md) |
| `bat` | Catppuccin syntax-highlighting themes | [details](docs/modules/bat.md) |
| `1password` | SSH agent, security settings, compact UI | [details](docs/modules/1password.md) |
| `claude` | Claude Code settings, 31 plugins, custom statusline | [details](docs/modules/claude.md) |
| `codex` | Codex profiles (code, plan, review) on Azure OpenAI | [details](docs/modules/codex.md) |
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

## Multi-distro support

The file `zsh/.zshrc.d/00-distro.zsh` detects the running distro and exports `$DOTFILES_DISTRO`. Distro-specific alias files (`pkg-ubuntu.zsh`, `pkg-fedora.zsh`, `pkg-opensuse.zsh`) self-guard — they return immediately on the wrong distro.

## Theme

Catppuccin **Macchiato** everywhere: Ghostty, tmux, Starship, Neovim, FZF, and bat.

## Docs

- [Dependencies](docs/guides/dependencies.md) — every tool with per-distro install commands
- [Setup guide](docs/guides/setup.md) — fresh machine walkthrough
- [Aliases cheatsheet](docs/guides/aliases.md) — every alias grouped by domain
- [Tmux keybindings](docs/guides/tmux-keybindings.md) — full key reference
- Per-module docs in [`docs/modules/`](docs/modules/)

## Contributing

See [AGENTS.md](AGENTS.md) for commit conventions, validation commands, and project structure.

## License

[Apache-2.0](LICENSE)
