# dotfiles for macOS

Personal configuration for a macOS environment themed around Catppuccin. Each top-level directory mirrors a tool and can be symlinked into place with GNU Stow.

## Highlights
- **Shell & Prompt** – `zsh/` provides modular startup files alongside modern CLI tooling (`zoxide`, `eza`, `fd`, `ripgrep`, `fzf`, `bat`). `starship/` contains the prompt theme.
- **Editor** – `nvim/.config/nvim/` bootstraps LazyVim with custom keymaps, options, and plugin specs tracked via `lazy-lock.json`.
- **Terminal Workflow** – `tmux/.config/tmux/tmux.conf` ships pane/session ergonomics, while `git/` and `gh/` hold Git and GitHub CLI defaults.
- **Automation & Agents** – `codex/` and `opencode/` capture AI tooling settings; `ssh/` centralises client preferences and allowed signers.

## Usage
Clone into `~/.dotfiles` and deploy modules as needed:

```bash
git clone https://github.com/rahulnakmol/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow -n zsh   # preview symlinks
stow zsh      # apply module
```

Re-run `stow <module>` after changes to keep `$HOME` in sync. See `AGENTS.md` for contributor guidance, testing tips, and GitHub CLI workflows.
