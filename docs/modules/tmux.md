# tmux

Tmux configuration with Catppuccin Macchiato theme, custom key tables for Claude Code and OpenCode, and vim-style navigation.

## Key Files

| File | Purpose |
|------|---------|
| `.config/tmux/tmux.conf` | Full tmux configuration |

## Core Settings

| Setting | Value |
|---------|-------|
| Prefix | `C-a` (rebound from `C-b`) |
| Terminal | `tmux-256color` with truecolor passthrough |
| Mouse | Enabled |
| Base index | 1 (windows and panes) |
| Renumber windows | On |

## Navigation (prefix-free)

| Key | Action |
|-----|--------|
| `M-Arrow` | Move between panes |
| `C-h/j/k/l` | Pane navigation (via vim-tmux-navigator) |
| `M-H` / `M-L` | Previous / next window |

## Splits and Pane Management (C-a +)

| Key | Action |
|-----|--------|
| `'` | Split horizontal |
| `\` | Split vertical |
| `x` | Smart kill (instant for shell, confirm for running processes) |
| `r` | Reload config |

## AI Tool Key Tables

### Claude Code (`C-a c` then key)

| Key | Action |
|-----|--------|
| `c` / `Enter` | Popup session (80x80%) |
| `/` | One-shot prompt via `claude -p` |
| `s` | Split with Sonnet (acceptEdits) |
| `o` | Split with Opus (acceptEdits) |
| `a` | Split with Opus autopilot (skip-permissions) |
| `p` | Split with Opus plan mode (read-only) |
| `w` | New window |

### OpenCode (`C-a o` then key)

| Key | Action |
|-----|--------|
| `o` / `Enter` | Popup session |
| `/` | One-shot run prompt |
| `s` | Split with default model |
| `w` | New window |
| `p` | Popup with Opus |
| `c` | Popup with GPT Codex |
| `u` | Popup with Gemini Pro |
| `q` | Popup with MiniMax |

## Theme

Catppuccin Macchiato with rounded window status style, bottom status bar, application + session status modules.

## Plugins (via TPM)

| Plugin | Purpose |
|--------|---------|
| `tmux-plugins/tpm` | Plugin manager (auto-bootstraps on first run) |
| `tmux-plugins/tmux-sensible` | Sensible defaults |
| `christoomey/vim-tmux-navigator` | Seamless vim/tmux pane navigation |
| `catppuccin/tmux` | Theme |
| `tmux-plugins/tmux-yank` | System clipboard integration |

## Dependencies

tmux, git (for TPM bootstrap).
