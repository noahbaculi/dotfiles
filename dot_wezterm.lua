-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This table will hold the configuration.
local config = wezterm.config_builder()

local function get_appearance()
  if wezterm.gui then
    return wezterm.gui.get_appearance()
  end
  return "Dark"
end

-- See themes at https://wezterm.org/colorschemes/index.html
local function scheme_for_appearance(appearance)
  if appearance:find("Dark") then
    return "catppuccin-frappe"
    -- return "nightfox"
    -- return "Everforest Dark (Gogh)"
  else
    return "catppuccin-latte"
    -- return "dawnfox"
    -- return "Everforest Light (Gogh)"
  end
end

config.color_scheme = scheme_for_appearance(get_appearance())

config.hide_tab_bar_if_only_one_tab = true
config.native_macos_fullscreen_mode = true
config.font_size = 14

config.keys = {
  {
    key = "c",
    mods = "CTRL",
    action = wezterm.action.CopyTo("ClipboardAndPrimarySelection"),
  },
  {
    key = "v",
    mods = "CTRL",
    action = wezterm.action.PasteFrom("Clipboard"),
  },
}

return config
