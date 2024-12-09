local wezterm = require "wezterm"
local config = wezterm.config_builder()

config = {
    automatically_reload_config = true,
    enable_tab_bar = true,
    window_close_confirmation = "AlwaysPrompt",
    window_decorations = "INTEGRATED_BUTTONS|RESIZE",
    use_fancy_tab_bar = true,
    default_cursor_style = "BlinkingBar",
    color_scheme = "Catppuccin Macchiato (Gogh)",
    font = wezterm.font("ZedMono Nerd Font", { weight = "Regular", italic = true }),
    font_size = 18.0,
    background = {
        {
            source = {
                File = "/Users/rahulnakmol/.dotfiles/wezterm/.config/wezterm/background.png",
            },
            hsb = {
                hue = 1.0,
                brightness = 0.25,
                saturation = 1.02,
            },
            attachment = { Parallax = 0.1 },
            width = "100%",
            height = "100%",
            opacity = 0.65,
        },
        {
            source = {
                Color = "#24273a",
            },
            width = "100%",
            height = "100%",
            opacity = 0.55,
        }
    },
    window_padding = {
        left = 4,
        right = 4,
        top = 0,
        bottom = 0,
    },

}

return config
