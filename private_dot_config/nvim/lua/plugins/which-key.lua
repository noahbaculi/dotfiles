return {
  "folke/which-key.nvim",
  version = "1.6.0",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 200
  end,
  opts = {},
}
