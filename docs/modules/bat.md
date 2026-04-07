# bat

Syntax-highlighting pager used as a `cat` replacement. This module provides Catppuccin theme files.

## Files

| File | Purpose |
|------|---------|
| `themes/Catppuccin Macchiato.tmTheme` | Active theme (selected via `BAT_THEME` in `.zprofile`) |
| `themes/Catppuccin Frappe.tmTheme` | Alternative dark variant |
| `themes/Catppuccin Latte.tmTheme` | Light variant |
| `themes/Catppuccin Mocha.tmTheme` | Alternative dark variant |

## Setup

After stowing, rebuild the bat cache so it picks up the themes:

```bash
bat cache --build
```

## Integration

- `BAT_THEME="Catppuccin Macchiato"` is set in `zsh/.zprofile`
- The alias `cat` is mapped to `bat` in `zsh/.zshrc.d/aliases.zsh`
- `catt` alias runs `bat` with decorations (line numbers, grid)

## Dependencies

- [bat](https://github.com/sharkdp/bat)
