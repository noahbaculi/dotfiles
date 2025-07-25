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

-- Better indenting
vim.keymap.set("v", "<Tab>", ">gv", { desc = "Indent line" })
vim.keymap.set("v", "<S-Tab>", "<gv", { desc = "Unindent line" })

-- Keep cursor centered while navigating
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and keep cursor centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and keep cursor centered" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Move to next search result and keep cursor centered" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Move to previous search result and keep cursor centered" })

-- File operations
vim.keymap.set("n", "|", "<cmd>vsplit<cr>", { desc = "Vertical Split" })
vim.keymap.set("n", "\\", "<cmd>split<cr>", { desc = "Horizontal Split" })

-- Diagnostic keymaps
-- vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
-- vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
-- vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
-- vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- -- See `:help vim.highlight.on_yank()`
-- local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
-- vim.api.nvim_create_autocmd("TextYankPost", {
--   callback = function() vim.highlight.on_yank() end,
--   group = highlight_group,
--   pattern = "*",
-- })

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

-- Toggle comment
vim.keymap.set(
  "n",
  "<leader>/",
  function() require("Comment.api").toggle.linewise.count(vim.v.count > 0 and vim.v.count or 1) end,
  { desc = "Toggle comment line" }
)
vim.keymap.set("v", "<leader>/", "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>", { desc = "Toggle comment for selection" })

--
-- Which key groups
-- These should be vim.keymap.set() function calls

--
--
--
-- The fzf-lua allows opening of multiple selections directly into tabs but telescope does not
which_key.add({ "<leader>f", group = "Find", icon = "" })
vim.keymap.set("n", "<leader>fb", function() require("fzf-lua").buffers() end, { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fw", function() require("fzf-lua").grep_string() end, { desc = "Find current word" })
vim.keymap.set("n", "<leader>fC", function() require("fzf-lua").commands() end, { desc = "Find commands" })
vim.keymap.set("n", "<leader>ff", function() require("fzf-lua").files() end, { desc = "Find files" })
vim.keymap.set("n", "<leader>fo", function() require("fzf-lua").oldfiles({ only_cwd = true, include_current_session = true }) end, { desc = "Find old files" })
vim.keymap.set("n", "<leader>fs", function() require("fzf-lua").live_grep() end, { desc = "Find string in files" })
vim.keymap.set("n", "<leader>fS", function()
  require("telescope.builtin").live_grep({
    additional_args = function(args) return vim.list_extend(args, { "--hidden", "--no-ignore" }) end,
  })
end, { desc = "Find string in all files" })
vim.keymap.set("n", "<leader>fd", function() require("trouble").toggle("diagnostics") end, { desc = "Find Trouble diagnostics" })
vim.keymap.set("n", "<leader>ft", "<cmd>TodoFzfLua<cr>", { desc = "Find todos" })

--
--
--
which_key.add({ mode = { "n", "v" }, { "<leader>r", group = "Replace" } })
-- vim.keymap.set("n", "<leader>rw", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace word under cursor" })
vim.keymap.set("n", "<leader>rr", function() require("spectre").toggle() end, { desc = "Toggle Spectre replace" })
vim.keymap.set("n", "<leader>rw", function() require("spectre").open_visual({ select_word = true }) end, { desc = "Search current word" })
vim.keymap.set("v", "<leader>rw", '<esc><cmd>lua require("spectre").open_visual()<CR>', { desc = "Search current word" })
vim.keymap.set(
  "n",
  "<leader>rh",
  function() require("spectre").open_file_search({ select_word = true }) end,
  { desc = "Search current word in current file (here)" }
)
vim.keymap.set("v", "<leader>rh", '<esc><cmd>lua require("spectre").open_file_search()<CR>', { desc = "Search current word in current file (here)" })
vim.keymap.set(
  "n",
  "<leader>rA",
  [[:%s/\v("\/|")(caredb|courier|cronkite|dataengine|drow|identity|integrator|lachesis|oracle|overlord|pylon|showboat)(\/v\d\/\S{-})(\/"|")/"\/\2\3\/"/gc]],
  { desc = "Replace Carium API paths with slashes" }
)

--
--
--
which_key.add({ "<leader>p", group = "Plugins", icon = "" })
vim.keymap.set("n", "<leader>pl", function() require("lazy").home() end, { desc = "Lazy plugins" })
vim.keymap.set("n", "<leader>pm", "<cmd>Mason<cr>", { desc = "Mason plugins" })
vim.keymap.set("n", "<leader>pM", "<cmd>MasonUpdate<cr>", { desc = "Mason Update" })

--
--
--
which_key.add({ "<leader>u", group = "UI/UX", icon = "" })
vim.keymap.set("n", "<leader>ut", function() require("telescope.builtin").colorscheme({ enable_preview = true }) end, { desc = "Theme switcher" })
vim.keymap.set("n", "<leader>uw", function()
  vim.wo.wrap = not vim.wo.wrap
  vim.notify("Toggled Word Wrap", vim.log.levels.INFO, { title = "Word Wrap" })
end, { desc = "Toggle word wrap" })
vim.keymap.set("n", "<leader>uC", "<cmd>ColorizerToggle<cr>", { desc = "Toggle Colorizer" })
vim.keymap.set("n", "<leader>ud", "<cmd>Twilight<cr>", { desc = "Toggle Twilight dimming" })

--
--
--
which_key.add({ "<leader>b", group = "Buffers", icon = "󰓩" })
vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<cmd>write<cr>", { desc = "Save buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>BufferClose<cr>", { desc = "Delete buffer" })
vim.keymap.set("n", "<leader>c", "<cmd>BufferClose<cr>", { desc = "Delete buffer" })
vim.keymap.set("n", "<leader>bN", "<cmd>BufferMoveNext<cr>", { desc = "Move next buffer" })
vim.keymap.set("n", "<leader>bn", "<cmd>BufferNext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "]b", "<cmd>BufferNext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bP", "<cmd>BufferMovePrevious<cr>", { desc = "Move previous buffer" })
vim.keymap.set("n", "<leader>bp", "<cmd>BufferPrevious<cr>", { desc = "Previous buffer" })
vim.keymap.set("n", "[b", "<cmd>BufferPrevious<cr>", { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>bI", "<cmd>BufferPin<cr>", { desc = "Pin/Unpin buffer" })

--
--
--
which_key.add({ "<leader>g", group = "Git", icon = "󰊢" })
vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })

vim.keymap.set("n", "]g", function() require("gitsigns").next_hunk() end, { desc = "Next Git hunk" })
vim.keymap.set("n", "[g", function() require("gitsigns").prev_hunk() end, { desc = "Previous Git hunk" })
vim.keymap.set("n", "<leader>gl", function() require("gitsigns").blame_line() end, { desc = "View Git blame" })
vim.keymap.set("n", "<leader>gL", function() require("gitsigns").blame_line({ full = true }) end, { desc = "View full Git blame" })
vim.keymap.set("n", "<leader>gp", function() require("gitsigns").preview_hunk() end, { desc = "Preview Git hunk" })
vim.keymap.set("n", "<leader>gh", function() require("gitsigns").reset_hunk() end, { desc = "Reset Git hunk" })
vim.keymap.set("n", "<leader>gr", function() require("gitsigns").reset_buffer() end, { desc = "Reset Git buffer" })
vim.keymap.set("n", "<leader>gs", function() require("gitsigns").stage_hunk() end, { desc = "Stage Git hunk" })
vim.keymap.set("n", "<leader>gS", function() require("gitsigns").stage_buffer() end, { desc = "Stage Git buffer" })
vim.keymap.set("n", "<leader>gu", function() require("gitsigns").undo_stage_hunk() end, { desc = "Unstage Git hunk" })
vim.keymap.set("n", "<leader>gd", function() require("gitsigns").diffthis() end, { desc = "View Git diff" })

--
--
--
which_key.add({ "<leader>s", group = "Session", icon = "󱂬" })
vim.keymap.set("n", "<leader>sl", "<cmd>SessionRestore<cr>", { desc = "Load last CWD session" })
vim.keymap.set("n", "<leader>sd", "<cmd>SessionDelete<cr>", { desc = "Delete last CWD session" })
vim.keymap.set("n", "<leader>sf", require("auto-session.session-lens").search_session, { desc = "Find session" })

--
--
--
which_key.add({ "<leader>w", group = "Wrap/surround", icon = "󰅪" })

--
--
--
which_key.add({ "<leader>l", group = "LSP", icon = "" })
vim.keymap.set("n", "<leader>li", "<cmd>LspInfo<cr>", { desc = "LSP information" })

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

    vim.keymap.set("n", "gd", function() require("telescope.builtin").lsp_definitions() end, { buffer = ev.buf, desc = "Go to definition" })
    vim.keymap.set("n", "gr", function() require("fzf-lua").lsp_references() end, { desc = "Find references" })
    vim.keymap.set("n", "gi", function() require("fzf-lua").lsp_implementations() end, { desc = "Find implementations" })
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = ev.buf, desc = "Go to declaration" })
    vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = ev.buf, desc = "Hover documentation" })
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, { buffer = ev.buf, desc = "Signature documentation" })
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev() end, { desc = "Previous diagnostic" })
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next() end, { desc = "Next diagnostic" })
    vim.keymap.set("n", "<leader>lt", function() require("fzf-lua").lsp_typedefs() end, { buffer = ev.buf, desc = "Type definition" })
    vim.keymap.set("n", "<leader>ls", function() require("aerial").toggle() end, { desc = "Toggle Aerial symbols outline" })
    vim.keymap.set("n", "<leader>lD", function() require("fzf-lua").diagnostics_document() end, { desc = "Search diagnostics" })
    vim.keymap.set("n", "<leader>ld", function() vim.diagnostic.open_float() end, { desc = "Hover diagnostics" })
    vim.keymap.set("n", "<leader>lA", function() vim.lsp.buf.code_action() end, { desc = "LSP code action" })
    vim.keymap.set("n", "<leader>la", function() require("actions-preview").code_actions() end, { desc = "LSP code action (previewed)" })
    vim.keymap.set("n", "<leader>lr", function() vim.lsp.buf.rename() end, { desc = "Rename current symbol" })
    vim.keymap.set("n", "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, { buffer = ev.buf, desc = "Format buffer" })
    vim.keymap.set("n", "<leader>lh", vim.lsp.buf.hover, { buffer = ev.buf, desc = "Hover documentation" })
    vim.keymap.set("n", "<leader>lH", function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end, { desc = "Toggle Inlay Hints" })
    vim.keymap.set("n", "<leader>lm", function() require("ferris.methods.view_memory_layout") end, { desc = "View Memory Layout" })
  end,
})
