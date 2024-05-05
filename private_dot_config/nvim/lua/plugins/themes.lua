return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    version = "1.7.0",
    lazy = false,
    priority = 1000,
    integrations = {
      indent_blankline = {
        enabled = true,
        scope_color = "",
        colored_indent_levels = false,
      },
    },
  },
  {
    "folke/tokyonight.nvim",
    version = "3.0.1",
    lazy = false,
    priority = 1000,
  },
  {
    "marko-cerovac/material.nvim",
    commit = "772e41a7f33743224f30799a3a887dc7dd853f8d",
    lazy = false,
    priority = 1000,
    opts = {
      plugins = {
        "gitsigns",
        "illuminate",
        "indent-blankline",
        "noice",
        "nvim-cmp",
        "nvim-tree",
        "nvim-web-devicons",
        "telescope",
        "trouble",
        "which-key",
        "nvim-notify",
      },
    },
  },
  {
    "EdenEast/nightfox.nvim",
    version = "3.9.3",
    lazy = false,
    priority = 1000,
  },
  {
    "sainnhe/everforest",
    version = "0.3.0",
    lazy = false,
    priority = 1000,
  },
}
