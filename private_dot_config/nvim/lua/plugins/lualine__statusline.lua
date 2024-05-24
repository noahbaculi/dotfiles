return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = {
    { "nvim-tree/nvim-web-devicons" },
    {
      "AndreM222/copilot-lualine",
    },
    {
      "arkav/lualine-lsp-progress",
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
