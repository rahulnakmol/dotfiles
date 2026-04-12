# wezterm

GPU-accelerated terminal for WSL with Catppuccin Macchiato theme and agentic coding keybindings.

## Files

| File | Purpose |
|------|---------|
| `.config/wezterm/wezterm.lua` | WezTerm configuration (runs on Windows, manages WSL sessions) |

## Settings

| Setting | Value |
|---------|-------|
| Theme | Catppuccin Macchiato (Gogh) |
| Font | Mononoki Nerd Font, 16pt |
| Opacity | 0.95 with system backdrop blur |
| Tab bar | Bottom, retro style, Catppuccin colors |
| Window | 200x50, 20px padding, integrated title bar |
| Scrollback | 10,000 lines |

## Keybindings

### Tabs & Navigation

| Key | Action |
|-----|--------|
| `CTRL+T` | New tab (current domain) |
| `CTRL+SHIFT+T` | New tab (default domain / PowerShell) |
| `CTRL+W` | Close tab |
| `CTRL+ALT+1` | New PowerShell tab |
| `CTRL+ALT+2` | New WSL:Ubuntu tab |
| `F11` | Toggle fullscreen |

### AI Coding (launches in WSL:Ubuntu)

| Key | Action |
|-----|--------|
| `CTRL+SHIFT+C` | Split right with `claude` (interactive) |
| `CTRL+SHIFT+O` | Split right with `opencode` (interactive) |
| `CTRL+SHIFT+A` | New tab: claude autopilot (opus, skip permissions) |
| `CTRL+SHIFT+P` | New tab: claude plan mode (opus, read-only) |
| `CTRL+SHIFT+S` | New tab: claude sonnet (acceptEdits) |

## Deployment

WezTerm runs on Windows and reads its config from `%USERPROFILE%\.config\wezterm\`. Since stow targets the Linux `$HOME`, you need to create a symlink from Windows:

```bash
# From WSL, after stowing:
stow wezterm

# Create Windows symlink (run once from cmd.exe or PowerShell):
cmd.exe /c mklink /D "%USERPROFILE%\.config\wezterm" "\\\\wsl$\\Ubuntu\\home\\<user>\\.config\\wezterm"
```

Alternatively, copy the file manually whenever it changes.

## Dependencies

[WezTerm](https://wezfurlong.org/wezterm/) installed on Windows, Mononoki Nerd Font.
