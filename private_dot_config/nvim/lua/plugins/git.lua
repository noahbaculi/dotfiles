return {
  -- { "stevearc/dressing.nvim" },
  {
    "lewis6991/gitsigns.nvim",
    version = "0.7",
    event = "VeryLazy",
    config = function() require("gitsigns").setup() end,
  },
  {
    "kdheepak/lazygit.nvim",
    commit = "1e08e3f5ac1152339690140e61a4a32b3bdc7de5",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
}
