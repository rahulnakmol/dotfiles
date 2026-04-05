---
name: add-alias
description: Add a new shell alias to zsh/.zshrc.d/aliases.zsh following the repo naming conventions
---

Add a new alias to `zsh/.zshrc.d/aliases.zsh`. The user provides the alias details as arguments (e.g., `/add-alias docker` or a full alias definition).

## Conventions

Read `zsh/.zshrc.d/aliases.zsh` first. Follow these rules:

1. **Grouping**: Aliases are grouped by tool under `# Aliases for <tool>` headers. Place the new alias in the correct group, or create a new group if the tool doesn't have one yet.

2. **Naming prefix**: Alias names start with an abbreviation of the tool they wrap:
   - `g` for git, `gh` for GitHub CLI, `n` for npm, `t` for tmux, `az` for Azure CLI, `azd` for Azure Dev CLI, `b` for brew, `a` for apt, `s` for ssh

3. **Inline comments**: Every alias gets a trailing comment explaining what it does.

4. **Functions for complex logic**: If the alias needs arguments or conditionals, use a function (like `ssh_host()` or `spub()`) with a short alias pointing to it.

5. **Modern CLI tools**: Prefer `eza` over `ls`, `bat` over `cat`, `fd` over `find`, `rg` over `grep` where applicable.

## Steps

1. Read the current `zsh/.zshrc.d/aliases.zsh`
2. Determine the correct group and alias name
3. Add the alias following conventions above
4. Run `zsh -n zsh/.zshrc` to syntax-check
5. Show the user what was added
