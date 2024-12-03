return {
  "nvim-pack/nvim-spectre",
  cmd = { "Spectre" },
  opts = {
    -- MacOS fix to avoid new `-E` files
    -- https://github.com/nvim-pack/nvim-spectre/issues/118
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
  },
}
