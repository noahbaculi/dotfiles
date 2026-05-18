return {
  -- LSP Support
  {
    "neovim/nvim-lspconfig",
    event = { "VeryLazy" },
    config = function()
      vim.lsp.config("rust_analyzer", {
        settings = {
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
      })

      vim.lsp.config("tinymist", {})

      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      local servers = {
        { name = "taplo",         binary = "taplo" },
        { name = "yamlls",        binary = "yaml-language-server" },
        { name = "lua_ls",        binary = "lua-language-server" },
        { name = "biome",         binary = "biome" },
        { name = "rust_analyzer", binary = "rust-analyzer" },
        { name = "tinymist",      binary = "tinymist" },
        { name = "ruff",          binary = "ruff" },
      }

      for _, server in ipairs(servers) do
        if vim.fn.executable(server.binary) == 1 then
          vim.lsp.enable(server.name)
        end
      end
    end,
  },
  -- Autocompletion
  {
    "saghen/blink.cmp",
    version = "v1.*",
    event = { "InsertEnter" },
    dependencies = {
      {
        "windwp/nvim-autopairs",
        opts = {},
      },
      {
        "L3MON4D3/LuaSnip",
        build = "make install_jsregexp",
        dependencies = {
          { "rafamadriz/friendly-snippets" },
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
      { "fang2hou/blink-copilot" },
    },

    opts = {
      keymap = {
        preset = "none",
        ["<Up>"]   = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<C-p>"]  = { "select_prev", "fallback" },
        ["<C-n>"]  = { "select_next", "fallback" },
        ["<C-k>"]  = { "select_prev", "fallback" },
        ["<C-j>"]  = { "select_next", "fallback" },
        ["<C-e>"]  = { "hide", "fallback" },
        ["<CR>"]   = { "accept", "fallback" },
      },

      snippets = { preset = "luasnip" },

      sources = {
        default = { "lsp", "copilot", "snippets", "buffer", "path" },
        providers = {
          copilot = {
            name = "copilot",
            module = "blink-copilot",
            async = true,
          },
        },
      },

      completion = {
        menu = { border = "rounded" },
        documentation = {
          auto_show = true,
          window = { border = "rounded" },
        },
        list = {
          selection = {
            preselect = false,
            auto_insert = false,
          },
        },
      },

      appearance = {
        nerd_font_variant = "mono",
        kind_icons = {
          Copilot = "",
        },
      },

      fuzzy = {
        implementation = "prefer_rust_with_warning",
      },
    },

    config = function(_, opts)
      require("blink.cmp").setup(opts)
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
}
