return {
  "nvim-pack/nvim-spectre",
  cmd = { "Spectre" },
  replace_engine = {
    ["sed"] = {
      cmd = "sed",
      args = {
        "-i",
        "",
        "-E",
      },
    },
  },
}
