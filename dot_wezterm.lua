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
local theme_dir = os.getenv("HOME") .. "/.config/theme-switcher/"
local themes = dofile(theme_dir .. "themes.lua")

local function read_current_theme()
  local f = io.open(theme_dir .. "current-theme")
  if f then
    local name = f:read("*l")
    f:close()
    return name
  end
  return "catppuccin"
end

local function scheme_for_appearance(appearance)
  local family = themes[read_current_theme()] or themes["catppuccin"]
  local wez = family.wezterm or {}
  if appearance:find("Dark") then
    return wez.dark or "Catppuccin Frappe"
  else
    return wez.light or wez.dark or "Catppuccin Frappe"
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
  {
    key = "Enter",
    mods = "SHIFT",
    action = wezterm.action.SendString("\x1b[200~\n\x1b[201~"),
  },
}

return config
