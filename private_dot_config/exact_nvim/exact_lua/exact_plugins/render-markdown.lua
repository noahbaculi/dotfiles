-- In-buffer markdown rendering: heading icons, checkboxes, code block bg, tables.
return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
  ft = { "markdown" },
  keys = {
    { "<leader>um", "<cmd>RenderMarkdown toggle<cr>", ft = "markdown", desc = "Toggle markdown rendering" },
  },
  opts = {
    file_types = { "markdown" },
    heading = { position = "inline" },
  },
}
