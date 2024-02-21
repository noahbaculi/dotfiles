-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

--- Check if a plugin is defined in lazy. Useful with lazy loading when a plugin is not necessarily loaded yet
---@param plugin string The plugin to search for
---@return boolean available # Whether the plugin is available
function Lazy_is_available(plugin)
	local lazy_config_avail, lazy_config = pcall(require, "lazy.core.config")
	return lazy_config_avail and lazy_config.spec.plugins[plugin] ~= nil
end

-- Install `lazy.nvim` plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup("plugins") -- Load plugins defined in the `plugins` directory

-- Configure LSP
local lsp_zero = require("lsp-zero")
lsp_zero.extend_lspconfig()
lsp_zero.on_attach(function(client, bufnr)
	-- see `:help lsp-zero-keybindings`
	lsp_zero.default_keymaps({ buffer = bufnr })
end)
require("mason").setup({})
require("mason-lspconfig").setup({
	handlers = {
		lsp_zero.default_setup,
	},
})

-- Set Vim options
require("options")

-- Basic Keymaps
require("keymaps")

vim.cmd.colorscheme("catppuccin") -- Set the default colorscheme
