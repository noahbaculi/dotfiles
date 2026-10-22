local lsp_status = ""

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = {
    { "nvim-tree/nvim-web-devicons" },
    { "AndreM222/copilot-lualine" },
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
      lualine_x = {
        {
          function() return lsp_status end,
          cond = function() return lsp_status ~= "" end,
        },
        "copilot",
        "encoding",
        "fileformat",
        "filetype",
      },
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
      "nvim-tree",
      "oil",
      "trouble",
    },
  },
  config = function(_, opts)
    require("lualine").setup(opts)
    -- Cache per event since vim.lsp.status() consumes the progress queue
    vim.api.nvim_create_autocmd("LspProgress", {
      callback = function(ev)
        lsp_status = ev.data.params.value.kind == "end" and "" or vim.lsp.status()
        require("lualine").refresh()
      end,
    })
  end,
}
