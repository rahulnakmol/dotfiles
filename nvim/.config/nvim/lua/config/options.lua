-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- These optional providers are not used by this configuration. Language tooling
-- runs through LSP, DAP, Mason, and project-local executables instead.
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

-- Use Prettier only when the repository explicitly opts in with a config file.
-- Biome and Oxc remain repository-specific alternatives.
vim.g.lazyvim_prettier_needs_config = true
