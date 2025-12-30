return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      -- Use a sub-list to run only the first available formatter
      lua = { "stylua", stop_after_first = true },
      markdown = { "mdformat", stop_after_first = true },
      html = { "prettierd", stop_after_first = true },
      css = { "prettierd", stop_after_first = true },
      javascript = { "prettierd", stop_after_first = true },
      sql = { "sqlfluff", stop_after_first = true },
    },
    formatters = {
      sqlfluff = {
        stdin = false,
        args = { "fix", "$FILENAME" },
      },
    },
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },
  },
}
