-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║  wezterm.lua — Catppuccin Macchiato · WSL terminal, no Windows Ghostty build ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
--
-- Deploy: stow wezterm (inside WSL), then symlink it to where Windows looks:
--   cmd.exe /c mklink /D "%USERPROFILE%\.config\wezterm" "\\wsl$\<distro>\home\<user>\.config\wezterm"
--
-- ── Quick Reference ─────────────────────────────────────────────────────────
--
--   Tabs & Panes
--     CTRL+SHIFT+T        new tab, current domain (WSL if detected)
--     CTRL+SHIFT+ENTER    toggle fullscreen
--
--   AI Coding (uppercase, spawned into the WSL domain — mirrors tmux's own
--              C-a C / C-a O key tables, one layer up: from Windows straight
--              into a WSL pane, before you've even attached to tmux)
--     CTRL+SHIFT+C        split right → claude (interactive, sonnet)
--     CTRL+SHIFT+O        split right → opencode (interactive)
--     CTRL+SHIFT+A        new tab → claude autopilot (dangerously-skip-permissions)
--     CTRL+SHIFT+P        new tab → claude plan mode (opus, read-only)
--
-- ── Catppuccin Macchiato palette ────────────────────────────────────────────
--   base    #24273a    mauve   #c6a0f6    peach   #f5a97f
--   surface #363a4f    green   #a6da95    text    #cad3f5

local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- ── Font (matches Ghostty on native Linux) ──────────────────────────────────

config.font = wezterm.font("Mononoki Nerd Font")
config.font_size = 16
config.line_height = 1.2

-- ── Theme ────────────────────────────────────────────────────────────────────
-- "Catppuccin Macchiato (Gogh)" is the exact registered scheme name (WezTerm
-- ships several Catppuccin variants sourced from different upstreams —
-- Gogh, iTerm2-Color-Schemes' hyphenated "catppuccin-macchiato", etc.). A
-- misspelled name here fails silently and falls back to the default theme,
-- so this string is the one confirmed valid in WezTerm's own docs.
config.color_scheme = "Catppuccin Macchiato (Gogh)"

-- ── Window ───────────────────────────────────────────────────────────────────
-- Mirrors ghostty/.config/ghostty/config: 0.95 opacity, 20px padding.

config.window_background_opacity = 0.95
config.window_padding = {
  left = 20,
  right = 20,
  top = 20,
  bottom = 20,
}
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.initial_cols = 200
config.initial_rows = 50

-- ── Tab bar ──────────────────────────────────────────────────────────────────

config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = true

-- ── WSL domain ───────────────────────────────────────────────────────────────
-- Auto-discovered rather than a hardcoded distro name ("Ubuntu",
-- "Ubuntu-24.04", ...) — wezterm.default_wsl_domains() reads whatever `wsl -l
-- -v` actually reports on this machine. Falls back to the local domain
-- untouched when run somewhere WSL isn't installed at all (e.g. previewing
-- this config outside WSL), rather than erroring.
config.wsl_domains = wezterm.default_wsl_domains()

local wsl_domain_name = nil
for _, dom in ipairs(config.wsl_domains) do
  wsl_domain_name = dom.name
  break
end
if wsl_domain_name then
  config.default_domain = wsl_domain_name
end

-- ── AI coding keybindings ────────────────────────────────────────────────────
-- Uppercase, matching this repo's tmux convention of avoiding lowercase keys
-- that already carry meaning elsewhere. Spawns directly into the WSL domain
-- when one was found; falls back to the current pane's domain otherwise, so
-- this config doesn't error when previewed on plain Linux/macOS.

local act = wezterm.action
local wsl_target = wsl_domain_name and { DomainName = wsl_domain_name } or "CurrentPaneDomain"

config.keys = {
  {
    key = "C",
    mods = "CTRL|SHIFT",
    action = act.SplitPane({
      direction = "Right",
      command = { args = { "zsh", "-lc", "claude --model sonnet --permission-mode auto" }, domain = wsl_target },
    }),
  },
  {
    key = "O",
    mods = "CTRL|SHIFT",
    action = act.SplitPane({
      direction = "Right",
      command = { args = { "zsh", "-lc", "opencode" }, domain = wsl_target },
    }),
  },
  {
    key = "A",
    mods = "CTRL|SHIFT",
    action = act.SpawnCommandInNewTab({
      label = "Claude autopilot (sonnet)",
      args = { "zsh", "-lc", "claude --model sonnet --dangerously-skip-permissions" },
      domain = wsl_target,
    }),
  },
  {
    key = "P",
    mods = "CTRL|SHIFT",
    action = act.SpawnCommandInNewTab({
      label = "Claude plan mode (opus, read-only)",
      args = { "zsh", "-lc", "claude --model opus --permission-mode plan" },
      domain = wsl_target,
    }),
  },
}

return config
