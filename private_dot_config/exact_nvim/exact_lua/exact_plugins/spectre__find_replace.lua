return {
  "nvim-pack/nvim-spectre",
  cmd = { "Spectre" },
  keys = {
    { "<leader>rr", function() require("spectre").toggle() end, desc = "Toggle Spectre replace" },
    { "<leader>rw", function() require("spectre").open_visual({ select_word = true }) end, desc = "Search current word" },
    { "<leader>rw", '<esc><cmd>lua require("spectre").open_visual()<CR>', mode = "v", desc = "Search current word" },
    { "<leader>rh", function() require("spectre").open_file_search({ select_word = true }) end, desc = "Search current word in current file (here)" },
    { "<leader>rh", '<esc><cmd>lua require("spectre").open_file_search()<CR>', mode = "v", desc = "Search current word in current file (here)" },
  },
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
