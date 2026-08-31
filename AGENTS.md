# Dotfiles — GNU Stow

Each top-level folder is a stow module that symlinks into `$HOME`. Deploy: `stow <module>`. Dry-run: `stow -n <module>`.

## Modules
`1password` `bat` `claude` `codex` `cursor` `gh` `ghostty` `git` `nvim` `opencode` `ssh` `starship` `tmux` `wezterm` `zsh`

## Validation
- `zsh -n zsh/.zshrc` and every `zsh/.zshrc.d/*.zsh` file — syntax-check shell
- `shellcheck` every `.sh` file — see `.github/workflows/ci.yml` for the full list
- `stylua --check nvim/.config/nvim wezterm/.config/wezterm` — lint Lua (two-space indent, 120 cols; see `stylua.toml`)
- `tmux -f tmux/.config/tmux/tmux.conf -L audit new-session -d` — smoke-test tmux
- `node scripts/validate-agent-policy.mjs` — Claude/Codex/OpenCode/Cursor secret + shell policy parity vs `agent-policy/catalog.json` (regenerate: `node scripts/apply-agent-policy.mjs`)
- `ls ~/.claude/rules` / `ls ~/.cursor/rules` — verify the rule sets symlinked after `stow claude cursor`

## Multi-distro and WSL Support
Targets Ubuntu LTS (apt + Homebrew), Fedora (dnf), openSUSE Tumbleweed (zypper), and WSL2 (any
distro inside it). `00-platform.zsh` detects the distro (`$DOTFILES_DISTRO`) and WSL (`$DOTFILES_WSL`,
split 1 vs 2). Package manager aliases in `pkg-*.zsh` and the WSL files (`10-wsl.zsh`,
`11-clipboard.zsh`, `zz-wsl-aliases.zsh`) self-guard and only load on the matching platform. ZSH
plugins resolve from Homebrew prefix first, then `/usr/share/`.

## Skills
Agent behavior lives in [rahulnakmol/skills](https://github.com/rahulnakmol/skills), not in this
dotfiles repo. Bootstrap: `./scripts/bootstrap-skills.sh` (see `skills.manifest.yaml`, `docs/skills.md`).

## Conventions
- **Commits**: conventional format scoped to module — `feat(zsh): add fzf aliases`
- **Aliases**: universal in `aliases.zsh`, distro-specific in `pkg-*.zsh`, WSL-specific in
  `10-wsl.zsh`/`zz-wsl-aliases.zsh`, prefixed by utility (`g` git, `d` docker, `dn` dnf, `zy` zypper)
- **Theme**: Catppuccin Macchiato everywhere
- **CLI tools**: `eza` over ls, `bat` over cat, `fd`/`rg` over find/grep, `zoxide` for cd
- **Agent policy**: Claude/Codex/OpenCode/Cursor permissions are generated from
  `agent-policy/catalog.json` — edit the catalog, not the adapters directly

## Security
Never commit tokens or keys. `.gitignore` blocks `hosts.yml`, `.env`, SSH private keys and
`authorized_keys`, and the credential files agent-policy's catalog names. Secrets go in 1Password
or `~/.zshrc.local`. Commit signing is configured per machine, on demand, via
`scripts/setup-signing-key.sh` — never a hardcoded 1Password path in the committed config. Azure
AI Foundry / ChatGPT Pro auth for Codex and OpenCode is configured the same way, on demand, via
`scripts/setup-model-provider.sh` — no `--api-key` flag, no secret ever written to a tracked file.
