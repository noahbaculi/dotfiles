return {
  "f-person/auto-dark-mode.nvim",
  lazy = false,
  config = {
    update_interval = 1e3, -- milliseconds
    set_dark_mode = function()
      -- vim.api.nvim_set_option("background", "dark")
      vim.opt.background = "dark"
      vim.cmd.colorscheme("nightfox")
    end,
    set_light_mode = function()
      -- vim.api.nvim_set_option("background", "light")
      vim.opt.background = "light"
      vim.cmd.colorscheme("material-lighter")
    end,
  },
}
