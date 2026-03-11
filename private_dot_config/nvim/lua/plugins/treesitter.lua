return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false, -- main branch does not support lazy-loading
    build = ":TSUpdate",
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    opts = {
      highlight = { enable = true },
      indent = { enable = true },
    },
    config = function(_, opts)
      require("nvim-treesitter").setup(opts)

      require("nvim-treesitter").install({
        "bash",
        "diff",
        "json",
        "lua",
        "toml",
        "yaml",
        "markdown",
        "markdown_inline",
        "rust",
        "python",
        "sql",
        "regex",
        "html",
        "javascript",
        "typescript",
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = { "VeryLazy" },
    dependencies = {
      { "nvim-treesitter/nvim-treesitter", branch = "main" },
    },
    init = function()
      -- Prevent conflicts with built-in ftplugin mappings
      vim.g.no_plugin_maps = true
    end,
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = {
          lookahead = true,
          selection_modes = {
            ["@function.outer"] = "V", -- linewise
            ["@class.outer"] = "V", -- linewise
          },
        },
        move = {
          set_jumps = true,
        },
      })

      -- Select keymaps
      local select = require("nvim-treesitter-textobjects.select")
      vim.keymap.set({ "x", "o" }, "af", function() select.select_textobject("@function.outer", "textobjects") end, { desc = "Select outer function" })
      vim.keymap.set({ "x", "o" }, "if", function() select.select_textobject("@function.inner", "textobjects") end, { desc = "Select inner function" })
      vim.keymap.set({ "x", "o" }, "ac", function() select.select_textobject("@class.outer", "textobjects") end, { desc = "Select outer class" })
      vim.keymap.set({ "x", "o" }, "ic", function() select.select_textobject("@class.inner", "textobjects") end, { desc = "Select inner class" })

      -- Move keymaps
      local move = require("nvim-treesitter-textobjects.move")
      vim.keymap.set({ "n", "x", "o" }, "]f", function() move.goto_next_start("@function.outer", "textobjects") end, { desc = "Next function start" })
      vim.keymap.set({ "n", "x", "o" }, "]c", function() move.goto_next_start("@class.outer", "textobjects") end, { desc = "Next class start" })
      vim.keymap.set({ "n", "x", "o" }, "]F", function() move.goto_next_end("@function.outer", "textobjects") end, { desc = "Next function end" })
      vim.keymap.set({ "n", "x", "o" }, "]C", function() move.goto_next_end("@class.outer", "textobjects") end, { desc = "Next class end" })
      vim.keymap.set({ "n", "x", "o" }, "[f", function() move.goto_previous_start("@function.outer", "textobjects") end, { desc = "Prev function start" })
      vim.keymap.set({ "n", "x", "o" }, "[c", function() move.goto_previous_start("@class.outer", "textobjects") end, { desc = "Prev class start" })
      vim.keymap.set({ "n", "x", "o" }, "[F", function() move.goto_previous_end("@function.outer", "textobjects") end, { desc = "Prev function end" })
      vim.keymap.set({ "n", "x", "o" }, "[C", function() move.goto_previous_end("@class.outer", "textobjects") end, { desc = "Prev class end" })

      -- Swap keymaps
      local swap = require("nvim-treesitter-textobjects.swap")
      vim.keymap.set({ "n" }, "<leader>l<right>", function() swap.swap_next("@parameter.inner", "textobjects") end, { desc = "Swap next parameter" })
      vim.keymap.set({ "n" }, "<leader>l<left>", function() swap.swap_previous("@parameter.inner", "textobjects") end, { desc = "Swap prev parameter" })
    end,
  },

  -- Show context of the current function
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "VeryLazy",
    opts = { mode = "cursor", max_lines = 3 },
    keys = {
      {
        "<leader>uc",
        function()
          local tsc = require("treesitter-context")
          tsc.toggle()
          local _, tsc_enabled = debug.getupvalue(tsc.toggle, 1)
          if tsc_enabled then
            vim.notify("Enabled Treesitter Context", vim.log.levels.INFO, { title = "Treesitter Context" })
          else
            vim.notify("Disabled Treesitter Context", vim.log.levels.WARN, { title = "Treesitter Context" })
          end
        end,
        desc = "Toggle Treesitter Context",
      },
    },
  },
}
