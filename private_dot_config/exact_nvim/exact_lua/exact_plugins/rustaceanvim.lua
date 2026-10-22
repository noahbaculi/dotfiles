return {
  "mrcjkb/rustaceanvim",
  version = "^9",
  lazy = false, -- plugin lazy-loads itself on Rust filetypes
  init = function()
    -- Function form defers blink capabilities until rust-analyzer starts
    vim.g.rustaceanvim = function()
      return {
        server = {
          capabilities = require("blink.cmp").get_lsp_capabilities(),
          default_settings = {
            ["rust-analyzer"] = {
              -- Settings at https://rust-analyzer.github.io/book/configuration.html
              check = {
                command = "clippy",
                -- features = "all",
              },
              cargo = {
                -- features = "all",
                allTargets = true,
              },
            },
          },
        },
      }
    end
  end,
}
