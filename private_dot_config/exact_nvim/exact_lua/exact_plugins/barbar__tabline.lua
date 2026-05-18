return {
  "romgrk/barbar.nvim",
  event = "VeryLazy",
  dependencies = {
    "lewis6991/gitsigns.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "<leader>bd", "<cmd>BufferClose<cr>", desc = "Delete buffer" },
    { "<leader>c", "<cmd>BufferClose<cr>", desc = "Delete buffer" },
    { "<leader>bN", "<cmd>BufferMoveNext<cr>", desc = "Move next buffer" },
    { "<leader>bn", "<cmd>BufferNext<cr>", desc = "Next buffer" },
    { "]b", "<cmd>BufferNext<cr>", desc = "Next buffer" },
    { "<leader>bP", "<cmd>BufferMovePrevious<cr>", desc = "Move previous buffer" },
    { "<leader>bp", "<cmd>BufferPrevious<cr>", desc = "Previous buffer" },
    { "[b", "<cmd>BufferPrevious<cr>", desc = "Previous buffer" },
    { "<leader>bI", "<cmd>BufferPin<cr>", desc = "Pin/Unpin buffer" },
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
