return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = "FzfLua",
  keys = {
    { "<leader>fb", function() require("fzf-lua").buffers() end, desc = "Find buffers" },
    { "<leader>fw", function() require("fzf-lua").grep_cword() end, desc = "Find current word" },
    { "<leader>fC", function() require("fzf-lua").commands() end, desc = "Find commands" },
    { "<leader>ff", function() require("fzf-lua").files() end, desc = "Find files" },
    { "<leader>fo", function() require("fzf-lua").oldfiles({ cwd_only = true, include_current_session = false }) end, desc = "Find old files" },
    { "<leader>fs", function() require("fzf-lua").live_grep() end, desc = "Find string in files" },
    { "<leader>fS", function() require("fzf-lua").live_grep({ rg_opts = "--hidden --no-ignore --column --line-number --no-heading --color=always --smart-case" }) end, desc = "Find string in all files" },
    { "<leader>ft", "<cmd>TodoFzfLua<cr>", desc = "Find todos" },  -- depends on todo-comments.nvim
    { "<leader>ut", function() require("fzf-lua").colorschemes() end, desc = "Theme switcher" },
  },
  config = function()
    local actions = require("fzf-lua").actions
    actions = {
      -- Below are the default actions, setting any value in these tables will override
      -- the defaults, to inherit from the defaults change [1] from `false` to `true`
      files = {
        true, -- uncomment to inherit all the below in your custom config
        -- Pickers inheriting these actions:
        --   files, git_files, git_status, grep, lsp, oldfiles, quickfix, loclist,
        --   tags, btags, args, buffers, tabs, lines, blines
        -- `file_edit_or_qf` opens a single selection or sends multiple selection to quickfix
        -- replace `enter` with `file_edit` to open all files/bufs whether single or multiple
        -- replace `enter` with `file_switch_or_edit` to attempt a switch in current tab first
        ["enter"] = actions.file_edit,
        ["ctrl-s"] = actions.file_split,
        ["ctrl-v"] = actions.file_vsplit,
        ["ctrl-t"] = actions.file_tabedit,
        ["alt-q"] = actions.file_sel_to_qf,
        ["alt-Q"] = actions.file_sel_to_ll,
        ["alt-i"] = actions.toggle_ignore,
        ["alt-h"] = actions.toggle_hidden,
        ["alt-f"] = actions.toggle_follow,
      },
    }

    require("fzf-lua").setup({
      actions = actions,
      fzf_colors = true,
      fzf_opts = {
        ["--layout"] = "default",
      },
    })

    require("fzf-lua").register_ui_select()
  end,
}
