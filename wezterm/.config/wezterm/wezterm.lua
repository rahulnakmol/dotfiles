-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║  wezterm.lua — Catppuccin Macchiato · WSL terminal with agentic coding    ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
--
-- Deploy: stow wezterm (inside WSL), then symlink to Windows:
--   cmd.exe /c mklink /D "%USERPROFILE%\.config\wezterm" "\\wsl$\Ubuntu\home\<user>\.config\wezterm"
--
-- ── Quick Reference ─────────────────────────────────────────────────────────
--
--   Tabs & Navigation
--     CTRL+T              new tab (current domain)
--     CTRL+SHIFT+T        new tab (default domain / PowerShell)
--     CTRL+W              close tab
--     CTRL+ALT+1          new PowerShell tab
--     CTRL+ALT+2          new WSL:Ubuntu tab
--     F11                 toggle fullscreen
--
--   AI Coding (launch in WSL:Ubuntu)
--     CTRL+SHIFT+C        split right → claude (interactive)
--     CTRL+SHIFT+O        split right → opencode (interactive)
--     CTRL+SHIFT+A        new tab → claude autopilot (opus)
--     CTRL+SHIFT+P        new tab → claude plan mode (opus, read-only)
--     CTRL+SHIFT+S        new tab → claude sonnet (acceptEdits)
--
-- ── Catppuccin Macchiato palette ────────────────────────────────────────────
--   base    #24273a    mauve   #c6a0f6    peach   #f5a97f
--   surface #363a4f    green   #a6da95    text    #cad3f5

local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- ── Font (consistent with Ghostty) ──────────────────────────────────────────

config.font = wezterm.font("Mononoki Nerd Font")
config.font_size = 16
config.line_height = 1.2

-- ── Theme ───────────────────────────────────────────────────────────────────

config.color_scheme = "Catppuccin Macchiato (Gogh)"

-- ── Window ──────────────────────────────────────────────────────────────────

config.initial_cols = 200
config.initial_rows = 50
config.max_fps = 120
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_background_opacity = 0.95
config.win32_system_backdrop = "Auto"
config.window_padding = {
  left = 20,
  right = 20,
  top = 20,
  bottom = 20,
}

-- ── Tab bar (Catppuccin Macchiato retro style) ──────────────────────────────

config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.tab_and_split_indices_are_zero_based = true
config.hide_tab_bar_if_only_one_tab = true

config.colors = {
  tab_bar = {
    background = "#24273a",
    active_tab = {
      bg_color = "#c6a0f6",
      fg_color = "#24273a",
      intensity = "Normal",
      underline = "None",
      italic = true,
      strikethrough = false,
    },
    inactive_tab = {
      bg_color = "#24273a",
      fg_color = "#c6a0f6",
      intensity = "Normal",
      underline = "None",
      italic = false,
      strikethrough = false,
    },
    inactive_tab_hover = {
      bg_color = "#363a4f",
      fg_color = "#c6a0f6",
      intensity = "Normal",
      underline = "None",
      italic = false,
      strikethrough = false,
    },
    new_tab = {
      bg_color = "#24273a",
      fg_color = "#c6a0f6",
      intensity = "Normal",
      underline = "None",
      italic = false,
      strikethrough = false,
    },
  },
}

-- ── Scrollback ──────────────────────────────────────────────────────────────

config.scrollback_lines = 10000

-- ── Keybindings ─────────────────────────────────────────────────────────────

config.keys = {
  -- Tab management
  {
    key = "w",
    mods = "CTRL",
    action = wezterm.action.CloseCurrentTab({ confirm = false }),
  },
  {
    key = "t",
    mods = "CTRL",
    action = wezterm.action.SpawnTab("CurrentPaneDomain"),
  },
  {
    key = "t",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SpawnTab("DefaultDomain"),
  },
  {
    key = "F11",
    mods = "CTRL",
    action = wezterm.action.ToggleFullScreen,
  },

  -- Domain switching
  {
    key = "1",
    mods = "CTRL|ALT",
    action = wezterm.action.SpawnTab("DefaultDomain"),
  },
  {
    key = "2",
    mods = "CTRL|ALT",
    action = wezterm.action.SpawnTab({ DomainName = "WSL:Ubuntu" }),
  },

  -- ── AI Coding — Claude Code ─────────────────────────────────────────────

  -- CTRL+SHIFT+C → split right with claude (interactive session)
  {
    key = "c",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SplitPane({
      direction = "Right",
      size = { Percent = 50 },
      command = {
        domain = { DomainName = "WSL:Ubuntu" },
        args = { "claude" },
      },
    }),
  },

  -- CTRL+SHIFT+A → new tab with claude autopilot (opus, skip permissions)
  {
    key = "a",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SpawnCommandInNewTab({
      domain_name = "WSL:Ubuntu",
      args = { "claude", "--model", "opus", "--dangerously-skip-permissions" },
    }),
  },

  -- CTRL+SHIFT+P → new tab with claude plan mode (opus, read-only)
  {
    key = "p",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SpawnCommandInNewTab({
      domain_name = "WSL:Ubuntu",
      args = { "claude", "--model", "opus", "--permission-mode", "plan" },
    }),
  },

  -- CTRL+SHIFT+S → new tab with claude sonnet (acceptEdits)
  {
    key = "s",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SpawnCommandInNewTab({
      domain_name = "WSL:Ubuntu",
      args = { "claude", "--model", "sonnet", "--permission-mode", "acceptEdits" },
    }),
  },

  -- ── AI Coding — OpenCode ────────────────────────────────────────────────

  -- CTRL+SHIFT+O → split right with opencode (interactive session)
  {
    key = "o",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SplitPane({
      direction = "Right",
      size = { Percent = 50 },
      command = {
        domain = { DomainName = "WSL:Ubuntu" },
        args = { "opencode" },
      },
    }),
  },
}

return config
