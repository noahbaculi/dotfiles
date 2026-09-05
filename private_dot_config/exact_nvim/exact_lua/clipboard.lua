-- Route yanks to the local terminal via OSC 52 in remote (ssh/mosh) sessions.
-- Paste from the unnamed register because OSC 52 reads never survive mosh or zellij.
-- Must run before any `has('clipboard')` call, so before lazy loads plugins.
if vim.env.SSH_CONNECTION == nil and vim.env.SSH_TTY == nil then
  return
end

local osc52 = require("vim.ui.clipboard.osc52")

local function paste() return { vim.fn.getreg("", 1, true), vim.fn.getregtype("") } end

vim.g.clipboard = {
  name = "OSC 52 (remote)",
  -- mosh 1.4.0 only relays the `c` selector, so send `*` as `+` too
  copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("+") },
  paste = { ["+"] = paste, ["*"] = paste },
}
