return {
  "RRethy/vim-illuminate",
  commit = "305bf07b919ac526deb5193280379e2f8b599926",
  event = "VeryLazy",
  config = function()
    require("illuminate").configure({
      filetypes_denylist = {
        "alpha",
        "NvimTree",
      },
    })
  end,
}
