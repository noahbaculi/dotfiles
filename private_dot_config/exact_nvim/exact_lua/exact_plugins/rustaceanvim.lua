return {
  "mrcjkb/rustaceanvim",
  version = "^9",
  lazy = false, -- plugin lazy-loads itself on Rust filetypes
  init = function()
    vim.g.rustaceanvim = {
      server = {
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
  end,
}
