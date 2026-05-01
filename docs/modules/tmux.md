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

> Key tables use uppercase `C` / `O` so that the default tmux bindings
> `c` (new-window) and `o` (next-pane) keep working. The config explicitly
> rebinds `c` and `o` after reload to defeat any stale server state.

### Claude Code (`C-a C` then key)

| Key | Action |
|-----|--------|
| `c` / `Enter` | Popup session (80x80%) |
| `/` | One-shot prompt via `claude --model haiku -p` |
| `s` | Split with Sonnet (`--permission-mode auto`) |
| `o` | Split with Opus (`--permission-mode auto`) |
| `S` | Split with Sonnet autopilot (`--dangerously-skip-permissions`) |
| `O` | Split with Opus autopilot (`--dangerously-skip-permissions`) |
| `p` | Split with Opus plan mode (read-only) |
| `w` | New window |

Lowercase = safer (per-action classifier); uppercase = autopilot.

### OpenCode (`C-a O` then key)

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
| `catppuccin/tmux` | Theme (v2.3.0+ syntax) |
| `tmux-plugins/tmux-yank` | System clipboard integration |
| `tmux-plugins/tmux-cpu` | CPU / RAM module for status bar |
| `tmux-plugins/tmux-battery` | Battery module for status bar |
| `olimorris/tmux-pomodoro-plus` | Pomodoro timer module |

## Dependencies

- `tmux` 3.3a+ (Catppuccin v2.3.0 requires modern interpolation)
- `git` (for TPM bootstrap)
- A clipboard backend for `tmux-yank`:
  - X11: `xclip` or `xsel` — `sudo apt install xclip`
  - Wayland: `wl-clipboard` — `sudo apt install wl-clipboard`
- `tmux-battery` reads `/sys/class/power_supply/BAT*` and renders empty on
  desktops; safe to leave loaded.
