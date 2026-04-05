# Repository Guidelines

## Project Structure & Module Organization
Top-level folders mirror each tool. `zsh/` houses `.zshrc`, `.zprofile`, and modular `.zshrc.d/` (see `aliases.zsh` for helpers built around `zoxide`, `eza`, `fd`, `rg`, `fzf`, `bat`). `nvim/.config/nvim/` bootstraps LazyVim with options in `lua/config/` and plugin specs under `lua/plugins/`. Store tmux config in `tmux/.config/tmux/tmux.conf`, prompts in `starship/.config/starship.toml`, and CLI credentials in `gh/`, `codex/`, `opencode/`, and `ssh/`.

## Build, Test, and Development Commands
- `stow -n <module>` — dry-run symlinks.
- `stow <module>` — deploy into `$HOME`.
- `stylua --check nvim/.config/nvim` — lint Lua configuration.
- `tmux -f tmux/.config/tmux/tmux.conf -L audit new-session -d` — smoke-test tmux.
- `zsh -n zsh/.zshrc` — syntax-check shell scripts.

## Coding Style & Naming Conventions
Follow `stylua.toml` (two-space indents, 120-column width) or run LazyVim’s `:Lazy format`. Keep `.zshrc.d/` snippets single-purpose with lowercase, hyphenated filenames, comment macOS-only tweaks inline, group tmux key tables by feature, and prefix aliases with the utility they wrap for quick tracing.

## Modern CLI Utility Conventions
Rely on the modern toolchain: `zoxide` for navigation (`zl`, `prj`), `eza` for listings, `fd`/`rg` to feed `fzf`, and `bat --style=numbers` for previews. Add new helpers in `zsh/.zshrc.d/aliases.zsh`, mirroring the existing patterns.

## GitHub CLI Workflow
Authenticate using `ghl` and confirm status with `ghs`. Clone repos through `gcl`, sync via `gsync`, open pull requests with `gpc`, review in `gpv`, list via `gprs`, and check out branches using `gpx`. Triage issues using `gil`/`gic`, scan releases with `grls`, and rely on `gcx*` helpers for Codex defaults. Each alias mirrors the underlying `gh` subcommand (`gcl` → `gh repo clone`, `gpc` → `gh pr create`), so drop back to the raw CLI when scripting needs non-aliased names.

## Testing Guidelines
Run `stylua --check`, `zsh -n`, and the tmux smoke test after edits. Exercise fuzzy flows with `fzf --preview 'bat {}'` and reach for `rg --type-add 'zsh:*.zsh' "<keyword>"` when auditing helpers. Prefer dry runs like `ghs` or `ssh -F ssh/.ssh/config -G example.com` for credentialed tooling.

## Commit & Pull Request Guidelines
Use conventional commits (`feat(zsh): add fzf aliases`) and keep each commit focused on a single module to simplify `stow` rollbacks. Submit pull requests with `gpc`, link relevant issues, and list post-install steps (e.g., `stow nvim`, `:Lazy sync`). Add screenshots or terminal captures for visual changes.

### Git Aliases
Default shortcuts in `zsh/.zshrc.d/aliases.zsh` mirror Git’s subcommands (`gs` → `git status`, `ga` → `git add`, `gco` → `git checkout`, `gpl` → `git pull`, `gdiffs` → `git diff --staged`). Use them for daily work, but fall back to full commands when scripting or sharing one-off snippets with teammates unfamiliar with the aliases.

## Security & Configuration Tips
Never commit personal tokens or host entries—redact `gh/hosts.yml`, `ssh/allowed_signers`, and `codex` credentials before pushing. Favor environment variables or 1Password for secrets and ensure new SSH files keep strict permissions (`chmod 600`).
