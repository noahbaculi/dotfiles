return {
  "RRethy/vim-illuminate",
  event = "VeryLazy",
  config = function()
    require("illuminate").configure({
      filetypes_denylist = {
        "alpha",
        "NvimTree",
        "aerial",
        "spectre_panel",
      },
    })
  end,
}
