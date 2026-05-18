return {
  "folke/trouble.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<leader>fd", function() require("trouble").toggle("diagnostics") end, desc = "Find Trouble diagnostics" },
  },
  opts = {},
}
