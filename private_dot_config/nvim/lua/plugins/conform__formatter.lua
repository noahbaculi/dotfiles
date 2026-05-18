return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      -- Use a sub-list to run only the first available formatter
      lua = { "stylua", stop_after_first = true },
      markdown = function(bufnr)
        local dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":h")
        local found = vim.fs.find({ "dprint.json", "dprint.jsonc", ".dprint.json" }, { upward = true, path = dir, type = "file" })[1]
        if found then
          return { "dprint", stop_after_first = true }
        end
        return { "prettierd", stop_after_first = true }
      end,
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
