# nvim

Neovim configuration built on LazyVim with Catppuccin theme and extensive language/tool extras.

## Key Files

| File | Purpose |
|------|---------|
| `.config/nvim/init.lua` | Entrypoint, loads `config.lazy` |
| `.config/nvim/lua/config/lazy.lua` | Lazy.nvim bootstrap and plugin spec |
| `.config/nvim/lua/plugins/colorscheme.lua` | Sets Catppuccin as the colorscheme |
| `.config/nvim/lazyvim.json` | LazyVim extras manifest |
| `.config/nvim/stylua.toml` | StyLua formatter config |

## LazyVim Extras

Enabled via `lazyvim.json`:

**AI**: claudecode

**Languages**: cmake, docker, dotnet, git, go, json, markdown, python, rust, sql, svelte, tailwind, terraform, toml, typescript, yaml

**Editor**: fzf, neo-tree, outline, telescope

**Formatting**: biome, black

**LSP**: neoconf

**Utilities**: dot, gh, gitui, mini-hipatterns, project

**Other**: dap.core, test.core, coding.yanky

## Colorscheme

Catppuccin (`catppuccin/nvim`) set as the default via LazyVim opts.

## StyLua Config

| Setting | Value |
|---------|-------|
| Indent type | Spaces |
| Indent width | 2 |
| Column width | 120 |

## Plugin Management

- Lazy.nvim auto-bootstraps from git on first run
- Plugin update checker enabled (silent, no notifications)
- Disabled runtime plugins: gzip, tarPlugin, tohtml, tutor, zipPlugin

## Dependencies

Neovim (0.9+), git, a Nerd Font.
