return {
  "f-person/auto-dark-mode.nvim",
  lazy = false,
  opts = {
    update_interval = 1e3, -- milliseconds
    set_dark_mode = function()
      vim.opt.background = "dark"
      vim.cmd.colorscheme(require("theme-map").get_nvim_colorscheme("dark"))
    end,
    set_light_mode = function()
      vim.opt.background = "light"
      vim.cmd.colorscheme(require("theme-map").get_nvim_colorscheme("light"))
    end,
  },
}
