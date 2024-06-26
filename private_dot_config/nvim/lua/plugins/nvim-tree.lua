return {
  "nvim-tree/nvim-tree.lua",
  cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeOpen" },
  dependencies = {
    { "nvim-tree/nvim-web-devicons" },
    {
      "JMarkin/nvim-tree.lua-float-preview",
      opts = {
        toggled_on = false,
        scroll_lines = 20,
        window = {
          style = "minimal",
          relative = "win",
          border = "rounded",
          wrap = false,
        },
        mapping = {
          down = { "<C-j>" }, -- scroll down in preview
          up = { "<C-k>" }, -- scroll up in preview
          toggle = { "<C-Space>" },
        },
        -- hooks if return false preview doesn't shown
        hooks = {
          pre_open = function(path)
            -- if file > 5 MB or not text -> not preview
            local size = require("float-preview.utils").get_size(path)
            if type(size) ~= "number" then
              return false
            end
            local is_text = require("float-preview.utils").is_text(path)
            return size < 5 and is_text
          end,
          post_open = function(bufnr) return true end,
        },
      },
    },
  },
  -- https://github.com/nvim-tree/nvim-tree.lua/blob/master/doc/nvim-tree-lua.txt
  opts = {
    filters = {
      git_ignored = false,
    },
    view = {
      number = true,
      relativenumber = true,
      width = { min = 30, max = -1, padding = 1 },
    },
    renderer = {
      special_files = {},
      symlink_destination = false,
      highlight_opened_files = "all",
      indent_markers = { enable = true },
    },
    update_focused_file = {
      enable = true,
      update_root = false,
    },

    on_attach = function(bufnr)
      local api = require("nvim-tree.api")
      require("float-preview").attach_nvimtree(bufnr)

      -- default mappings
      api.config.mappings.default_on_attach(bufnr)
    end,
  },
}
