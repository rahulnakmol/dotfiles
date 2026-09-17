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

**Languages**: docker, dotnet, go, helm, json, markdown, Python, rust, SQL, Tailwind, terraform, toml, typescript, yaml

**Editor**: Snacks picker and explorer

**Formatting**: Prettier, only for repositories with a Prettier configuration

**API tooling**: REST and GraphQL requests through Kulala

**Other**: dap.core, test.core

## Keyboard-first workflow

`<leader>` is `Space`. Press `<leader>sk` at any time to search every active keymap.

### Files, search, buffers, and windows

| Key | Action |
| --- | --- |
| `<leader><space>` / `<leader>ff` | Find files from the project root |
| `<leader>fg` | Find Git-tracked files |
| `<leader>/` / `<leader>sg` | Grep the project |
| `<leader>sw` | Search the word or visual selection |
| `<leader>e` | Toggle Snacks Explorer |
| `<leader>,` | Pick an open buffer |
| `Shift-H` / `Shift-L` | Previous / next buffer |
| `<leader>bd` | Delete the current buffer |
| `Ctrl-H/J/K/L` | Move between Neovim windows |
| `<leader>-` / `<leader>|` | Split below / right |
| `<leader>wm` | Toggle window zoom |

### Code and diagnostics

| Key | Action |
| --- | --- |
| `gd` / `gr` | Go to definition / references |
| `gI` / `gy` | Go to implementation / type definition |
| `K` / `gK` | Hover / signature help |
| `<leader>ca` | Code action |
| `<leader>cr` | Rename symbol |
| `<leader>cR` | Rename file |
| `<leader>co` | Organize imports |
| `<leader>cf` | Format |
| `<leader>cd` | Show line diagnostics |
| `]d` / `[d` | Next / previous diagnostic |
| `]e` / `[e` | Next / previous error |
| `<leader>xx` | Open diagnostics in Trouble |

### Git, tests, and debugging

| Key | Action |
| --- | --- |
| `<leader>gg` | Open LazyGit at the project root |
| `<leader>gs` / `<leader>gd` / `<leader>gl` | Git status / diff / log |
| `]h` / `[h` | Next / previous Git hunk |
| `<leader>tr` / `<leader>tt` | Run nearest test / test file |
| `<leader>tl` / `<leader>to` | Run last test / show output |
| `<leader>ts` / `<leader>tw` | Toggle test summary / watch |
| `<leader>td` | Debug nearest test |
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Run or continue debugger |
| `<leader>di` / `<leader>dO` / `<leader>do` | Step into / over / out |
| `<leader>du` | Toggle DAP UI |
| `<leader>dt` | Terminate debug session |

### Claude, Python, SQL, and REST

| Key | Action |
| --- | --- |
| `<leader>ac` / `<leader>af` | Toggle / focus Claude Code |
| `<leader>ar` | Resume Claude Code |
| `<leader>ab` | Add current buffer to Claude |
| `<leader>as` | Send visual selection to Claude |
| `<leader>aa` / `<leader>ad` | Accept / deny Claude diff |
| `<leader>cv` | Select Python virtual environment |
| `<leader>D` | Toggle the SQL database UI |
| `<leader>Rs` / `<leader>Rr` | Send / replay an HTTP request |
| `<leader>Rn` / `<leader>Rp` | Next / previous request |
| `<leader>Rc` | Copy request as cURL |

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
- `lazy-lock.json` pins plugin revisions across machines
- Plugin update checker enabled (silent, no notifications)
- Disabled runtime plugins: gzip, tarPlugin, tohtml, tutor, zipPlugin

Run the deterministic bootstrap after deploying the module:

```bash
~/.dotfiles/scripts/bootstrap-nvim.sh
```

It restores locked plugins, synchronously installs the reviewed Mason toolset, installs every
configured Tree-sitter parser, retries one transient Mason failure, and exits nonzero if required
tools remain unavailable.

Framework and formatter extras such as Svelte, Prisma, Biome, Oxc, CMake, and Black are intentionally
repository-specific rather than part of the global baseline. Python uses Pyright and Ruff; no global
pip or Black installation is required. SQL uses SQLFluff and Dadbod; database-specific clients remain
external dependencies.

## Bun and Turborepo

The TypeScript extra uses VTSLS for Bun workspaces and Turborepo monorepos. Project-local `tsconfig`
and package boundaries remain the source of truth.

| Key | Action |
| --- | --- |
| `<leader>Br` | Run the current file with Bun |
| `<leader>Bt` | Run project tests with `bun test` |
| `<leader>BT` | Test the current file |
| `<leader>Bs` | Prompt for and run a package script |
| `<leader>Bf` | Run a script through a Bun workspace filter |
| `<leader>Bu` | Run a Turborepo task through `bunx turbo` |

LazyVim's JavaScript DAP configuration remains Node-specific. Bun uses the WebKit Inspector Protocol,
so the configuration does not pretend that `pwa-node` is a supported Bun debugger. Use Bun's web
debugger for interactive Bun debugging until a stable standalone Bun DAP adapter is available.

## Dependencies

Neovim 0.11.2+, git, a C compiler, Node.js, Go, the .NET SDK, Rust with rust-analyzer, and a Nerd Font.
For a rustup minimal profile, install the required component explicitly:

```bash
rustup component add rust-analyzer
```
