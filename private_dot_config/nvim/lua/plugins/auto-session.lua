return {
  "rmagatti/auto-session",
  event = "VeryLazy",
  opts = {
    auto_restore = false,
  },
  keys = {
    { "<leader>sl", "<cmd>AutoSession restore<cr>", desc = "Load last CWD session" },
    { "<leader>sd", "<cmd>AutoSession delete<cr>", desc = "Delete last CWD session" },
    { "<leader>sf", "<cmd>AutoSession search<cr>", desc = "Find session" },
  },
}
