return {
  "catgoose/nvim-colorizer.lua",
  cmd = { "ColorizerToggle" },
  keys = {
    { "<leader>uC", "<cmd>ColorizerToggle<cr>", desc = "Toggle Colorizer" },
  },
  opts = {
    user_default_options = {
      -- Available modes for `mode`: foreground, background,  virtualtext
      mode = "virtualtext", -- Set the display mode.
    },
  },
}
