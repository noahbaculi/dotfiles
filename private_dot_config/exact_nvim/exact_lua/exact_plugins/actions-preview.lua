return {
  "aznhe21/actions-preview.nvim",
  lazy = true,
  keys = {
    { "<leader>la", function() require("actions-preview").code_actions() end, desc = "LSP code action (previewed)" },
  },
  config = function()
    require("actions-preview").setup({
      backend = { "snacks" },
    })
  end,
}
