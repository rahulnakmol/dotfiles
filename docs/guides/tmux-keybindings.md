# Tmux Keybindings

Prefix: **`C-a`** (Ctrl+a). Theme: Catppuccin Macchiato.

Source: `tmux/.config/tmux/tmux.conf`

---

## Core

| Key | Action |
|-----|--------|
| `C-a` | Prefix (replaces default `C-b`) |
| `C-a r` | Reload tmux config |
| `C-a x` | Smart kill pane -- instant for shell, confirms for running processes |

## Navigation (prefix-free)

These work without pressing the prefix key first.

| Key | Action |
|-----|--------|
| `M-Left` | Move to pane on the left |
| `M-Right` | Move to pane on the right |
| `M-Up` | Move to pane above |
| `M-Down` | Move to pane below |
| `C-h` | Move to pane on the left (vim-tmux-navigator) |
| `C-j` | Move to pane below (vim-tmux-navigator) |
| `C-k` | Move to pane above (vim-tmux-navigator) |
| `C-l` | Move to pane on the right (vim-tmux-navigator) |
| `M-H` | Previous window |
| `M-L` | Next window |

## Splits and Panes

| Key | Action |
|-----|--------|
| `C-a '` | Split horizontal (pane below) |
| `C-a \` | Split vertical (pane right) |

Both splits open in the current pane's working directory.

## Claude Code Key Table (`C-a c` then...)

Press `C-a c` to enter the Claude key table, then press one of:

| Key | Action |
|-----|--------|
| `c` or `Enter` | Popup session (80% width/height) |
| `/` | One-shot prompt -- type a question, get an answer in a popup |
| `s` | Split pane with Sonnet (acceptEdits mode) |
| `o` | Split pane with Opus (acceptEdits mode) |
| `a` | Split pane with Opus autopilot (skip permissions) |
| `p` | Split pane with Opus plan mode (read-only) |
| `w` | New window running Claude |

## OpenCode Key Table (`C-a o` then...)

Press `C-a o` to enter the OpenCode key table, then press one of:

| Key | Action |
|-----|--------|
| `o` or `Enter` | Popup session (80% width/height) |
| `/` | One-shot run -- type a prompt, run headless in a popup |
| `s` | Split pane with OpenCode (default model) |
| `w` | New window running OpenCode |
| `p` | Popup with Pro model (Claude Opus) |
| `c` | Popup with Codex model (GPT) |
| `u` | Popup with UI model (Gemini) |
| `q` | Popup with Quick model (MiniMax) |

## Plugins

| Plugin | Purpose |
|--------|---------|
| `tpm` | Tmux Plugin Manager |
| `tmux-sensible` | Sensible default options |
| `vim-tmux-navigator` | Seamless `C-h/j/k/l` navigation between vim and tmux panes |
| `catppuccin/tmux` | Catppuccin Macchiato status bar theme |
| `tmux-yank` | System clipboard integration for copy mode |

TPM bootstraps automatically on first launch. To install plugins manually: `C-a I` (capital I).

## Settings

| Option | Value |
|--------|-------|
| Terminal | `tmux-256color` with true color override |
| Mouse | Enabled |
| Base index | 1 (windows and panes start at 1) |
| Renumber windows | On |
| Passthrough | On (for image protocols) |
