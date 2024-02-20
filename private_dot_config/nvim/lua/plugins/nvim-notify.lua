return {
  "rcarriga/nvim-notify",
  version = "3.3.13",
  config = function()
    vim.notify = require("notify")
  end,
}
