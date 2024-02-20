return {
  "nvim-tree/nvim-tree.lua",
  version = "0.100.0",
  cmd = { "NvimTreeToggle", "NvimTreeFocus" },
  dependencies = {
    { "nvim-tree/nvim-web-devicons" },
    {
      "JMarkin/nvim-tree.lua-float-preview",
      commit = "e45039ed81ba99ae0ce6c621a10b237258ecda10",
      -- default
      opts = {
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
          toggle = { "<Tab>" },
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
      local FloatPreview = require("float-preview")

      FloatPreview.attach_nvimtree(bufnr)

      local function opts(desc) return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true } end

      -- default mappings
      api.config.mappings.default_on_attach(bufnr)
      vim.keymap.del('n', '<Tab>', { buffer = bufnr }) -- handled by the float-preview plugin
    end,
  },
}
