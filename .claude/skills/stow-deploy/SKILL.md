---
name: stow-deploy
description: Dry-run and deploy a GNU Stow module with post-deploy validation (syntax checks, lint)
disable-model-invocation: true
---

Deploy a dotfiles stow module. The user provides the module name as an argument (e.g., `/stow-deploy zsh`).

## Steps

1. **Validate module exists**: Check that the directory `$ARGUMENTS/` exists in the repo root. If not, list available modules and stop.

2. **Dry-run**: Run `stow -n $ARGUMENTS` to check for conflicts.
   - If conflicts are found, report them and stop. Suggest `stow --adopt` if the target files already exist.

3. **Deploy**: Run `stow $ARGUMENTS` to create symlinks.

4. **Post-deploy validation** based on the module:

| Module | Validation Command |
|--------|--------------------|
| `zsh` | `zsh -n ~/.zshrc` |
| `nvim` | `stylua --check nvim/.config/nvim` |
| `tmux` | `tmux -f ~/.config/tmux/tmux.conf -L audit new-session -d && tmux -L audit kill-session` |
| `git` | `git config --global --list \| head -10` |
| `ssh` | `ssh -F ~/.ssh/config -G github.com 2>&1 \| head -5` |
| Other | Skip validation, just confirm symlinks were created |

5. **Report**: Show which symlinks were created or updated, and validation results.
