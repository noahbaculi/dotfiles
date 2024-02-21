return {
  "romgrk/barbar.nvim",
  commit = "71ac376acd000743146b1e08e62151b4d887bbac",
  event = "VeryLazy",
  dependencies = {
    "lewis6991/gitsigns.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    -- Automatically hide the tabline when there are this many buffers left.
    -- Set to any value >=0 to enable.
    auto_hide = 0,

    icons = {
      -- Use a preconfigured buffer appearance— can be 'default', 'powerline', or 'slanted'
      preset = "default",
    },

    insert_at_end = true,
    sidebar_filetypes = {
      NvimTree = { text = "NvimTree" },
    },
  },
}
