# starship

Starship cross-shell prompt with Catppuccin Macchiato palette.

## Key Files

| File | Purpose |
|------|---------|
| `.config/starship.toml` | Prompt configuration and palette definitions |

## Active Palette

`catppuccin_macchiato` -- all four Catppuccin flavors are defined (latte, frappe, macchiato, mocha) for easy switching.

## Module Customizations

| Module | Setting | Value |
|--------|---------|-------|
| `character` | Success symbol | green Nix logo + peach arrow |
| `character` | Error symbol | red Nix logo + peach arrow |
| `character` | Vim cmd symbol | subtext1 Nix logo + left arrow |
| `git_branch` | Style | bold mauve |
| `directory` | Truncation length | 4 |
| `directory` | Style | bold lavender |

## Palette Colors (Macchiato)

Key colors used in the prompt:

| Name | Hex |
|------|-----|
| peach | `#f5a97f` |
| green | `#a6da95` |
| red | `#ed8796` |
| mauve | `#c6a0f6` |
| lavender | `#b7bdf8` |
| subtext1 | `#b8c0e0` |

## Dependencies

starship, a Nerd Font (for glyph rendering).
