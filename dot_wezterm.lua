-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This table will hold the configuration.
local config = {}
-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

function get_appearance()
	if wezterm.gui then
		return wezterm.gui.get_appearance()
	end
	return "Dark"
end

local function scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "Solarized (dark) (terminal.sexy)"
	else
		return "Solarized (light) (terminal.sexy)"
	end
end

config.color_scheme = scheme_for_appearance(get_appearance())

config.hide_tab_bar_if_only_one_tab = true

config.native_macos_fullscreen_mode = true
config.font_size = 14

return config
