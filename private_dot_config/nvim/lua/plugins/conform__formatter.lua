return {
  "stevearc/conform.nvim",
  version = "5.3.0",
  opts = {
    formatters_by_ft = {
      -- Use a sub-list to run only the first available formatter
      lua = { { "stylua" } },
      markdown = { { "mdformat" } },
    },
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },
  },
}
