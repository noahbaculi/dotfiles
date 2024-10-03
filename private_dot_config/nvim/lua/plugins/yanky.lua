return {
  "gbprod/yanky.nvim",
  opts = {
    highlight = { timer = 150 },
  },
  keys = {
    { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank Text" },
    { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put Text After Cursor" },
    {
      "P",
      function() require("telescope").extensions.yank_history.yank_history({}) end,
      mode = { "n", "x" },
      desc = "Open Yank History",
    },
    { "[y", "<Plug>(YankyCycleForward)", desc = "Cycle Forward Through Yank History" },
    { "]y", "<Plug>(YankyCycleBackward)", desc = "Cycle Backward Through Yank History" },
  },
}
