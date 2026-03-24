return {
  "stevearc/aerial.nvim",
  cmd = { "AerialToggle", "AerialOpen", "AerialClose", "AerialInfo" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "<leader>ls", function() require("aerial").toggle() end, desc = "Toggle Aerial symbols outline" },
  },
  opts = {},
}
