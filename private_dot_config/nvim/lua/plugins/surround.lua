return {
  "echasnovski/mini.surround",
  event = "VeryLazy",
  opts = {
    highlight_duration = 500,

    -- Module mappings. Use `''` (empty string) to disable one.
    mappings = {
      add = "<leader>wa", -- Add surrounding in Normal and Visual modes
      delete = "<leader>wd", -- Delete surrounding
      find = "<leader>wf", -- Find surrounding (to the right)
      find_left = "<leader>wF", -- Find surrounding (to the left)
      highlight = "<leader>wh", -- Highlight surrounding
      replace = "<leader>wr", -- Replace surrounding
      update_n_lines = "<leader>wn", -- Update `n_lines`

      suffix_last = "l", -- Suffix to search with "prev" method
      suffix_next = "n", -- Suffix to search with "next" method
    },

    -- Number of lines within which surrounding is searched
    n_lines = 20,
  },
}
