# wezterm

WezTerm terminal configuration for WSL — Ghostty has no Windows build, so
this is the terminal on the Windows side of a WSL setup, not a Linux-native
alternative to Ghostty.

## Key Files

| File | Purpose |
|------|---------|
| `.config/wezterm/wezterm.lua` | Font, theme, window, WSL domain, AI-tool keybindings |

## Settings

| Setting | Value |
|---------|-------|
| Theme | Catppuccin Macchiato (Gogh) |
| Font | Mononoki Nerd Font, matching Ghostty |
| Font size | 16 |
| Window size | 200×50 cells |
| Padding | 20 |
| Background opacity | 0.95, matching Ghostty |
| Window decorations | Integrated buttons + resize |

## WSL domain

`wsl_domains` is populated via `wezterm.default_wsl_domains()` rather than a
hardcoded distro name — it reads whatever `wsl -l -v` actually reports on the
machine, so it doesn't break when the installed distro isn't literally named
"Ubuntu". `default_domain` is set to the first WSL domain found; if none are
found (for example, previewing this config outside WSL), it's left unset and
WezTerm falls back to its own default.

## AI coding keybindings

| Key | Action |
|-----|--------|
| `CTRL+SHIFT+C` | Split right → `claude` (sonnet, interactive) |
| `CTRL+SHIFT+O` | Split right → `opencode` (interactive) |
| `CTRL+SHIFT+A` | New tab → Claude autopilot (`--dangerously-skip-permissions`) |
| `CTRL+SHIFT+P` | New tab → Claude plan mode (opus, read-only) |

All four spawn into the discovered WSL domain when one exists, and fall back
to the current pane's domain otherwise — this config doesn't error when
previewed somewhere WSL isn't present.

## Deploy

Stow from inside WSL, then symlink the result to where Windows expects it —
WezTerm on Windows reads its config from `%USERPROFILE%\.config\wezterm`, not
from anywhere inside the WSL filesystem:

```
stow wezterm
cmd.exe /c mklink /D "%USERPROFILE%\.config\wezterm" "\\wsl$\<distro>\home\<user>\.config\wezterm"
```

## Dependencies

WezTerm (Windows), Mononoki Nerd Font, an installed WSL distribution.
