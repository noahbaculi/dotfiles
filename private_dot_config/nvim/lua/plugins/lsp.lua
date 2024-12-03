return {
  -- LSP Support
  {
    "neovim/nvim-lspconfig",
    event = { "VeryLazy" },
    dependencies = {
      {
        "hrsh7th/cmp-nvim-lsp",
      },
      {
        "VonHeikemen/lsp-zero.nvim",
        event = { "VeryLazy" },
      },
      {
        "williamboman/mason.nvim",
        event = { "VeryLazy" },
        opts = {},
      },
      {
        "williamboman/mason-lspconfig.nvim",
        event = { "VeryLazy" },
        opts = {
          ensure_installed = {
            "taplo", -- TOML
            "yamlls", -- YAML
            "lua_ls", -- Lua
            "rust_analyzer", -- Rust
            "ruff", -- Python formatter
            "pylyzer", -- Python
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
      require("mason-lspconfig").setup(
        -- handlers = {
        --   lsp_zero.default_setup,
        -- },
      )

      local lspconfig = require("lspconfig")
      lspconfig.rust_analyzer.setup({
        settings = {
          ["rust-analyzer"] = {
            check = {
              command = "clippy",
            },
            diagnostics = {
              enable = true,
            },
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
    event = { "VeryLazy" },

    dependencies = {
      {
        "windwp/nvim-autopairs",
        opts = {},
      },
      {
        "hrsh7th/cmp-cmdline",
      },
      {
        "onsails/lspkind.nvim",
      },
      {
        "L3MON4D3/LuaSnip",
        build = "make install_jsregexp", -- optional
        dependencies = {
          {
            "rafamadriz/friendly-snippets",
          },
          {
            "saadparwaiz1/cmp_luasnip",
          },
        },
      },
      {
        "zbirenbaum/copilot.lua",
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
        opts = {},
      },
    },

    config = function()
      local cmp = require("cmp")
      local lspkind = require("lspkind")
      require("luasnip.loaders.from_vscode").lazy_load()
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
        snippet = {
          expand = function(args) require("luasnip").lsp_expand(args.body) end,
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
