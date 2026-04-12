# Dotfiles — GNU Stow

Each top-level folder is a stow module that symlinks into `$HOME`. Deploy: `stow <module>`. Dry-run: `stow -n <module>`.

## Modules
`1password` `bat` `claude` `codex` `gh` `ghostty` `git` `nvim` `opencode` `ssh` `starship` `tmux` `wezterm` `zsh`

## Validation
- `zsh -n zsh/.zshrc` — syntax-check shell
- `stylua --check nvim/.config/nvim` — lint Lua (two-space indent, 120 cols)
- `tmux -f tmux/.config/tmux/tmux.conf -L audit new-session -d` ��� smoke-test tmux

## Multi-distro Support
Targets Ubuntu LTS (apt + Homebrew), Fedora (dnf), openSUSE Tumbleweed (zypper), and **WSL** (Ubuntu + Homebrew). `00-distro.zsh` detects the distro (`$DOTFILES_DISTRO`) and WSL (`$DOTFILES_WSL`). Package manager aliases in `pkg-*.zsh` and WSL-specific files (`01-wsl.zsh`, `02-wsl-aliases.zsh`) self-guard and only load on the matching environment. On WSL, 1Password SSH signing uses the Windows `op-ssh-sign-wsl` relay. ZSH plugins resolve from Homebrew prefix first, then `/usr/share/`.

## Conventions
- **Commits**: conventional format scoped to module — `feat(zsh): add fzf aliases`
- **Aliases**: universal in `aliases.zsh`, distro-specific in `pkg-*.zsh`, prefixed by utility (`g` git, `d` docker, `dn` dnf, `zy` zypper)
- **Theme**: Catppuccin Macchiato everywhere
- **CLI tools**: `eza` over ls, `bat` over cat, `fd`/`rg` over find/grep, `zoxide` for cd

## Security
Never commit tokens or keys. `.gitignore` blocks `hosts.yml`, `.credentials.json`, `.env`, SSH private keys. Secrets go in 1Password or env vars.
