return {
  "f-person/auto-dark-mode.nvim",
  lazy = false,
  opts = {
    update_interval = 1e3, -- milliseconds
    set_dark_mode = function()
      vim.opt.background = "dark"

      -- vim.cmd.colorscheme("catppuccin-frappe")
      -- vim.cmd.colorscheme("nightfox")

      -- vim.cmd.colorscheme("everforest")
      vim.cmd.colorscheme("rose-pine")

      -- vim.cmd.colorscheme("monokai-pro") -- Monokai doesn't seem to transition automatically from light to dark consistently
      -- vim.cmd.colorscheme("onedark")  -- OneDark doesn't seem to transition automatically from light to dark consistently
    end,
    set_light_mode = function()
      vim.opt.background = "light"

      -- vim.cmd.colorscheme("catppuccin-latte")
      -- vim.cmd.colorscheme("dawnfox")

      -- vim.cmd.colorscheme("everforest")
      vim.cmd.colorscheme("rose-pine")

      -- vim.cmd.colorscheme("monokai-pro-light") -- Monokai doesn't seem to transition automatically from light to dark consistently
      -- vim.cmd.colorscheme("onedark")  -- OneDark doesn't seem to transition automatically from light to dark consistently
    end,
  },
}
