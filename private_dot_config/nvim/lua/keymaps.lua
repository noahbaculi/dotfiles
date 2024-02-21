--
-- Navigation
--

vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Move line(s) like VSCode
vim.keymap.set("v", "J", ":m '>+1<CR>gv-gv", { desc = "Move line(s) down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv-gv", { desc = "Move line(s) up" })
-- vim.keymap.set("n", "???", ":m .+1<CR>==", { desc = "Move line(s) down" })
-- vim.keymap.set("n", "???", ":m .-2<CR>==", { desc = "Move line(s) up" })
-- vim.keymap.set("i", "???", "<Esc>:m .-2<CR>==gi", { desc = "Move line(s) up" })
-- vim.keymap.set("i", "???", "<Esc>:m .+1<CR>==gi", { desc = "Move line(s) down" })

-- Keep cursor centered while navigating
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and keep cursor centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and keep cursor centered" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Move to next search result and keep cursor centered" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Move to previous search result and keep cursor centered" })

-- File operations
vim.keymap.set("n", "<C-q>", "<cmd>qa!<cr>", { desc = "Force quit" })
vim.keymap.set("n", "|", "<cmd>vsplit<cr>", { desc = "Vertical Split" })
vim.keymap.set("n", "\\", "<cmd>split<cr>", { desc = "Horizontal Split" })

-- Diagnostic keymaps
-- vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
-- vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
-- vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
-- vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = "*",
})

--
-- Which Key
--
local which_key = require("which-key")

-- Base layer keymaps

-- When pasting over selected text, delete the selected text into the void register as to not override the clipboard
vim.keymap.set("n", "<leader>q", "<cmd>confirm q<cr>", { desc = "Quit" })
vim.keymap.set("n", "<leader>Q", "<cmd>confirm qall<cr>", { desc = "Quit all" })
vim.keymap.set("n", "<C-q>", "<cmd>confirm qall<cr>", { desc = "Quit all" })
vim.keymap.set("v", "<leader>p", [["_dP]], { desc = "Paste over selected text and discard selected text" })
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle Explorer" })
vim.keymap.set("n", "<leader>o", function()
	local nvimTree = require("nvim-tree.api")
	local currentBuf = vim.api.nvim_get_current_buf()
	local currentBufFt = vim.api.nvim_get_option_value("filetype", { buf = currentBuf })
	if currentBufFt == "NvimTree" then
		nvimTree.tree.toggle()
	else
		nvimTree.tree.focus()
	end
end, { desc = "Toggle Explorer Focus" })

-- Toggle comment
vim.keymap.set("n", "<leader>/", function()
	require("Comment.api").toggle.linewise.count(vim.v.count > 0 and vim.v.count or 1)
end, { desc = "Toggle comment line" })
vim.keymap.set(
	"v",
	"<leader>/",
	"<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>",
	{ desc = "Toggle comment for selection" }
)

-- Which key groups

-- These should be vim.keymap.set() function calls

which_key.register({ ["<leader>f"] = { name = " Find" } })
vim.keymap.set("n", "<leader>fb", function()
	require("telescope.builtin").buffers()
end, { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fc", function()
	require("telescope.builtin").grep_string()
end, { desc = "Find word under cursor" })
vim.keymap.set("n", "<leader>fC", function()
	require("telescope.builtin").commands()
end, { desc = "Find commands" })
vim.keymap.set("n", "<leader>ff", function()
	require("telescope.builtin").find_files()
end, { desc = "Find files" })
vim.keymap.set("n", "<leader>fo", function()
	require("telescope.builtin").oldfiles()
end, { desc = "Find recent files" })
vim.keymap.set("n", "<leader>ft", function()
	require("telescope.builtin").colorscheme({ enable_preview = true })
end, { desc = "Find themes" })
vim.keymap.set("n", "<leader>fw", function()
	require("telescope.builtin").live_grep()
end, { desc = "Find words" })
vim.keymap.set("n", "<leader>fW", function()
	require("telescope.builtin").live_grep({
		additional_args = function(args)
			return vim.list_extend(args, { "--hidden", "--no-ignore" })
		end,
	})
end, { desc = "Find words in all files" })
vim.keymap.set(
	"n",
	"<leader>fR",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = "Find and replace word under cursor" }
)
vim.keymap.set(
	"n",
	"<leader>fA",
	[[:%s/\v("\/|")(caredb|courier|cronkite|dataengine|drow|identity|integrator|lachesis|oracle|overlord|pylon|showboat)(\/v\d\/\S{-})(\/"|")/"\/\2\3\/"/gc]],
	{ desc = "Find and replace Carium API paths with slashes" }
)

which_key.register({ ["<leader>p"] = { name = "󰏖 Plugins" } })
vim.keymap.set("n", "<leader>pl", function()
	require("lazy").home()
end, { desc = "Lazy plugins" })
vim.keymap.set("n", "<leader>pm", "<cmd>Mason<cr>", { desc = "Mason plugins" })
vim.keymap.set("n", "<leader>pM", "<cmd>MasonUpdateAll<cr>", { desc = "Mason Update" })

which_key.register({ ["<leader>u"] = { name = " UI/UX" } })
vim.keymap.set("n", "<leader>ut", "<cmd>Telescope colorscheme<cr>", { desc = "Theme switcher" })

which_key.register({ ["<leader>b"] = { name = "󰓩 Buffers" } })
vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<cmd>write<cr>", { desc = "Save buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bd<cr>", { desc = "Delete buffer" })
vim.keymap.set("n", "<leader>c", "<cmd>bd<cr>", { desc = "Delete buffer" })
vim.keymap.set("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", "<cmd>bprev<cr>", { desc = "Previous buffer" })
vim.keymap.set("n", "[b", "<cmd>bprev<cr>", { desc = "Previous buffer" })

which_key.register({ ["<leader>g"] = { name = "󰊢 Git" } })
vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })

vim.keymap.set("n", "]g", function()
	require("gitsigns").next_hunk()
end, { desc = "Next Git hunk" })
vim.keymap.set("n", "[g", function()
	require("gitsigns").prev_hunk()
end, { desc = "Previous Git hunk" })
vim.keymap.set("n", "<leader>gl", function()
	require("gitsigns").blame_line()
end, { desc = "View Git blame" })
vim.keymap.set("n", "<leader>gL", function()
	require("gitsigns").blame_line({ full = true })
end, { desc = "View full Git blame" })
vim.keymap.set("n", "<leader>gp", function()
	require("gitsigns").preview_hunk()
end, { desc = "Preview Git hunk" })
vim.keymap.set("n", "<leader>gh", function()
	require("gitsigns").reset_hunk()
end, { desc = "Reset Git hunk" })
vim.keymap.set("n", "<leader>gr", function()
	require("gitsigns").reset_buffer()
end, { desc = "Reset Git buffer" })
vim.keymap.set("n", "<leader>gs", function()
	require("gitsigns").stage_hunk()
end, { desc = "Stage Git hunk" })
vim.keymap.set("n", "<leader>gS", function()
	require("gitsigns").stage_buffer()
end, { desc = "Stage Git buffer" })
vim.keymap.set("n", "<leader>gu", function()
	require("gitsigns").undo_stage_hunk()
end, { desc = "Unstage Git hunk" })
vim.keymap.set("n", "<leader>gd", function()
	require("gitsigns").diffthis()
end, { desc = "View Git diff" })

which_key.register({ ["<leader>S"] = { name = "󱂬 Session" } })

which_key.register({ ["<leader>t"] = { name = " Terminal" } })
vim.keymap.set("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", { desc = "ToggleTerm float" })
vim.keymap.set(
	"n",
	"<leader>th",
	"<cmd>ToggleTerm size=10 direction=horizontal<cr>",
	{ desc = "ToggleTerm horizontal split" }
)
vim.keymap.set(
	"n",
	"<leader>tv",
	"<cmd>ToggleTerm size=80 direction=vertical<cr>",
	{ desc = "ToggleTerm vertical split" }
)
vim.keymap.set({ "n", "t" }, "<F7>", "<cmd>ToggleTerm<cr>", { desc = "Toggle terminal" })
vim.keymap.set({ "n", "t" }, "<C-'>", "<cmd>ToggleTerm<cr>", { desc = "Toggle terminal" }) -- requires terminal that supports binding <C-'>
vim.keymap.set("n", "<leader>tl", "<cmd>ToggleTermSendCurrentLine<cr>", { desc = "ToggleTerm send line" })

--
-- LSP
--
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		-- Enable completion triggered by <c-x><c-o>
		vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

		vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, desc = "Go to definition" })
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = ev.buf, desc = "Go to declaration" })
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = ev.buf, desc = "Go to implementation" })
		vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = ev.buf, desc = "Go to references" })
		vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = ev.buf, desc = "Hover documentation" })
		vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, { buffer = ev.buf, desc = "Signature documentation" })

		which_key.register({ ["<leader>l"] = { name = " LSP" } })
		vim.keymap.set("n", "<leader>ls", function()
			require("aerial").toggle()
		end, { desc = "Toggle Aerial symbols outline" })
		vim.keymap.set("n", "<leader>lD", function()
			require("telescope.builtin").diagnostics()
		end, { desc = "Search diagnostics" })
		vim.keymap.set("n", "<leader>ld", function()
			vim.diagnostic.open_float()
		end, { desc = "Hover diagnostics" })
		vim.keymap.set("n", "[d", function()
			vim.diagnostic.goto_prev()
		end, { desc = "Previous diagnostic" })
		vim.keymap.set("n", "]d", function()
			vim.diagnostic.goto_next()
		end, { desc = "Next diagnostic" })
		vim.keymap.set("n", "<leader>li", "<cmd>LspInfo<cr>", { desc = "LSP information" })
		vim.keymap.set("n", "<leader>la", function()
			vim.lsp.buf.code_action()
		end, { desc = "LSP code action" })
		vim.keymap.set("n", "<leader>lr", function()
			vim.lsp.buf.rename()
		end, { desc = "Rename current symbol" })
		vim.keymap.set("n", "<leader>lt", vim.lsp.buf.type_definition, { buffer = ev.buf, desc = "Type definition" })
		vim.keymap.set("n", "<leader>lf", function()
			vim.lsp.buf.format({ async = true })
		end, { buffer = ev.buf, desc = "Format buffer" })
	end,
})
