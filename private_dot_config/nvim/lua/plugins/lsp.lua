return {
  -- LSP Support
  {
    "neovim/nvim-lspconfig",
    commit = "02c9b12eaf9393899bddb5ecf6670e7b3e5a4c49",
    event = { "VeryLazy" },
    dependencies = {
      {
        "hrsh7th/cmp-nvim-lsp",
        commit = "5af77f54de1b16c34b23cba810150689a3a90312",
      },
      {
        "VonHeikemen/lsp-zero.nvim",
        commit = "abac76482ec3012a2b359ba956a74e2ffd33d46f",
        event = { "VeryLazy" },
      },
      {
        "williamboman/mason.nvim",
        version = "1.10.0",
        event = { "VeryLazy" },
        opts = {},
      },
      {
        "williamboman/mason-lspconfig.nvim",
        version = "1.26.0",
        event = { "VeryLazy" },
        opts = {
          ensure_installed = {
            "taplo", -- TOML
            "yamlls", -- YAML
            "lua_ls", -- Lua
            -- "rust_analyzer", -- Rust
            "ruff_lsp", -- Python
            "biome", -- Javascript, Typescript, JSON
            -- "gopls", -- Go
            -- "sqlls", -- SQL
          },
          automatic_installation = true,
        },
      },
    },
    config = function()
      local lsp_zero = require("lsp-zero")
      lsp_zero.extend_lspconfig() -- Integrate lspconfig with nvim-cmp
      lsp_zero.on_attach(function(_, bufnr)
        -- see `:help lsp-zero-keybindings`
        lsp_zero.default_keymaps({ buffer = bufnr })
      end)
      require("mason-lspconfig").setup({
        handlers = {
          lsp_zero.default_setup,
        },
      })

      local lspconfig = require("lspconfig")
      lspconfig.rust_analyzer.setup({
        settings = {
          ["rust-analyzer"] = {
            cargo = {
              extraEnv = { CARGO_PROFILE_RUST_ANALYZER_INHERITS = "dev" },
              extraArgs = { "--profile", "rust-analyzer" },
            },
          },
        },
      })
    end,
  },
  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    commit = "04e0ca376d6abdbfc8b52180f8ea236cbfddf782",
    event = { "VeryLazy" },

    dependencies = {
      {
        "windwp/nvim-autopairs",
        commit = "2e8a10c5fc0dcaf8296a5f1a7077efcd37065cc8",
        opts = {},
      },
      {
        "hrsh7th/cmp-cmdline",
        commit = "8ee981b4a91f536f52add291594e89fb6645e451",
      },
      {
        "onsails/lspkind.nvim",
        commit = "1735dd5a5054c1fb7feaf8e8658dbab925f4f0cf",
      },
      {
        "L3MON4D3/LuaSnip",
        version = "2.2.0",
        build = "make install_jsregexp", -- optional
      },
      {
        "zbirenbaum/copilot.lua",
        commit = "03f825956ec49e550d07875d867ea6e7c4dc8c00",
        build = ":Copilot auth",
        opts = {
          suggestion = { enabled = false },
          panel = { enabled = false },
          filetypes = {
            yaml = true,
            markdown = true,
            help = true,
          },
        },
      },
      {
        "zbirenbaum/copilot-cmp",
        commit = "d427de01114f8d360de60f3eb569be52baf05d81",
        opts = {},
      },
    },

    config = function()
      local cmp = require("cmp")
      local lspkind = require("lspkind")
      cmp.setup({
        mapping = {
          ["<Up>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
          ["<Down>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-y>"] = cmp.config.disable,
          ["<C-e>"] = cmp.mapping({ i = cmp.mapping.abort(), c = cmp.mapping.close() }),
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "nvim_lsp_signature_help", priority = 1000 },
          { name = "copilot", priority = 900 },
          { name = "luasnip", priority = 750 },
          { name = "buffer", priority = 500 },
          { name = "path", priority = 250 },
        }),
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol",
            max_width = 50,
            symbol_map = { Copilot = "" },
          }),
        },
      })

      -- Insert a `(` after select function or method item
      cmp.event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())

      -- `:` cmdline setup.
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          {
            name = "cmdline",
            option = {
              ignore_cmds = { "Man", "!" },
            },
          },
        }),
      })
    end,
  },
}
