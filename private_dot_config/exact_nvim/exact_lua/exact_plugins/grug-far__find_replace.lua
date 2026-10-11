return {
  "MagicDuck/grug-far.nvim",
  cmd = { "GrugFar", "GrugFarWithin" },
  keys = {
    {
      "<leader>rr",
      function() require("grug-far").toggle_instance({ instanceName = "far", staticTitle = "Find and Replace" }) end,
      desc = "Toggle find and replace",
    },
    { "<leader>rw", function() require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } }) end, desc = "Search current word" },
    { "<leader>rw", function() require("grug-far").with_visual_selection() end, mode = "v", desc = "Search selection" },
    {
      "<leader>rh",
      function() require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>"), paths = vim.fn.expand("%") } }) end,
      desc = "Search current word in current file (here)",
    },
    {
      "<leader>rh",
      function() require("grug-far").with_visual_selection({ prefills = { paths = vim.fn.expand("%") } }) end,
      mode = "v",
      desc = "Search selection in current file (here)",
    },
  },
  opts = {
    -- Default replace is <localleader>r, which shadows the <leader>r group since both leaders are <Space>
    keymaps = { replace = { n = "<localleader>R" } },
  },
}
