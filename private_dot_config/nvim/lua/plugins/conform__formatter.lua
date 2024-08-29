return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      -- Use a sub-list to run only the first available formatter
      lua = { "stylua", stop_after_first = true },
      markdown = { "mdformat", stop_after_first = true },
      html = { "prettier", stop_after_first = true },
      css = { "prettier", stop_after_first = true },
      javascript = { "prettier", stop_after_first = true },
    },
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },
  },
}
