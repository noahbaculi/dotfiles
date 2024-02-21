return {
  "rcarriga/nvim-notify",
  version = "3.3.13",
  event = "VeryLazy",
  config = function() vim.notify = require("notify") end,
}
