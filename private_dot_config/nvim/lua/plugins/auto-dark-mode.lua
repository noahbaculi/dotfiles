return {
  "f-person/auto-dark-mode.nvim",
  lazy = false,
  dependencies = {
    "marko-cerovac/material.nvim",
  },
  opts = {
    update_interval = 1e3, -- milliseconds
    set_dark_mode = function()
      vim.opt.background = "dark"

      vim.cmd.colorscheme("catppuccin-frappe")
      -- vim.cmd.colorscheme("nightfox")
      -- vim.cmd.colorscheme("everforest")
      -- vim.cmd.colorscheme("nightfox")
    end,
    set_light_mode = function()
      vim.opt.background = "light"

      vim.cmd.colorscheme("catppuccin-latte")
      -- vim.cmd.colorscheme("material-lighter")
      -- vim.cmd.colorscheme("everforest")
      -- vim.cmd.colorscheme("dawnfox")
    end,
  },
}
