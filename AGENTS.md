# Dotfiles — GNU Stow

Each top-level folder is a stow module that symlinks into `$HOME`. Deploy: `stow <module>`. Dry-run: `stow -n <module>`.

## Modules
`1password` `claude` `codex` `gh` `ghostty` `git` `nvim` `opencode` `ssh` `starship` `tmux` `zsh`

## Validation
- `zsh -n zsh/.zshrc` — syntax-check shell
- `stylua --check nvim/.config/nvim` — lint Lua (two-space indent, 120 cols)
- `tmux -f tmux/.config/tmux/tmux.conf -L audit new-session -d` ��� smoke-test tmux

## Conventions
- **Commits**: conventional format scoped to module — `feat(zsh): add fzf aliases`
- **Aliases**: grouped by tool in `zsh/.zshrc.d/aliases.zsh`, prefixed by utility (`g` git, `d` docker, `t` tmux, `n` npm, `az` azure)
- **Theme**: Catppuccin Macchiato everywhere
- **CLI tools**: `eza` over ls, `bat` over cat, `fd`/`rg` over find/grep, `zoxide` for cd

## Security
Never commit tokens or keys. `.gitignore` blocks `hosts.yml`, `.credentials.json`, `.env`, SSH private keys. Secrets go in 1Password or env vars.
