local M = {}

local theme_dir = vim.fn.expand("~/.config/theme-switcher/")

function M.get_themes()
  return dofile(theme_dir .. "themes.lua")
end

function M.get_current_family()
  local f = io.open(theme_dir .. "current-theme")
  if f then
    local name = f:read("*l")
    f:close()
    return name
  end
  return "catppuccin"
end

function M.get_nvim_colorscheme(mode)
  local themes = M.get_themes()
  local family = themes[M.get_current_family()] or themes["catppuccin"]
  local nvim = family.nvim or {}
  if mode == "light" then
    return nvim.light or nvim.dark or "catppuccin-frappe"
  else
    return nvim.dark or "catppuccin-frappe"
  end
end

return M
