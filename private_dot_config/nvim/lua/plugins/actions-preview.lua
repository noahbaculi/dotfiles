return {
  "aznhe21/actions-preview.nvim",
  lazy = true,
  config = function()
    require("actions-preview").setup({
      backend = { "nui", "telescope" },
      nui = {
        dir = "col",
        layout = {
          relative = "editor",
          position = "50%",
          size = {
            width = "60%",
            height = "60%",
          },
        },
      },
    })
  end,
}
