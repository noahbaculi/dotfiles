return {
  "akinsho/bufferline.nvim",
  version = "4.5.0",
  event = "VeryLazy",
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    local bufferline = require("bufferline")
    bufferline.setup({
      options = {
        -- style_preset = bufferline.style_preset.minimal,  -- enable this to match the bg color

        indicator = {
          style = "underline",
        },
        buffer_close_icon = "x",
        separator_style = "slant",
        hover = {
          enabled = true,
          delay = 200,
          reveal = { "close" },
        },
        offsets = {
          {
            filetype = "NvimTree",
            text = function() return vim.fn.fnamemodify(vim.fn.getcwd(), ":t") end,
            highlight = "Directory",
            text_align = "left",
          },
        },
      },
    })
  end,
}
