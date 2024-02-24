return {
  "nvim-lualine/lualine.nvim",
  commit = "ea00644e98a306a54c11c7f2058a668c38876e6f",
  event = "VeryLazy",
  dependencies = {
    { "nvim-tree/nvim-web-devicons" },
    {
      "AndreM222/copilot-lualine",
      commit = "f7f0b3b3e7b0183d65fb5416c1d3e210e8a67ba6",
    },
    {
      "arkav/lualine-lsp-progress",
      commit = "56842d097245a08d77912edf5f2a69ba29f275d7",
    },
  },
  opts = {
    sections = {
      lualine_a = { "mode" },
      lualine_b = {
        "branch",
        "diff",
        {
          "diagnostics",
          sources = { "nvim_diagnostic" },
          symbols = { error = " ", warn = " ", info = " ", hint = " " },
        },
      },
      lualine_c = {
        -- 'filename'  -- Hide the filename since it is already displayed by bufferline
      },
      lualine_x = { "lsp_progress", "copilot", "encoding", "fileformat", "filetype" },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { "filename" },
      lualine_x = { "location" },
      lualine_y = {},
      lualine_z = {},
    },
    extensions = {
      "aerial",
      "fzf",
      "lazy",
      "mason",
      "nvim-tree",
      "oil",
      "symbols-outline",
      "toggleterm",
      "trouble",
    },
  },
}
