local ALPHA_possible_headers = {
  {
    [[_   _             _ __      ___]],
    [[| \ | |           | |\ \    / (_)]],
    [[|  \| | ___   __ _| |_\ \  / / _ _ __ ___]],
    [[| . ` |/ _ \ / _` | '_ \ \/ / | | '_ ` _ \]],
    [[| |\  | (_) | (_| | | | \  /  | | | | | | |]],
    [[|_| \_|\___/ \__,_|_| |_|\/   |_|_| |_| |_| ]],
  },
  {
    [[.------..------..------..------..------..------..------.]],
    [[|N.--. ||O.--. ||A.--. ||H.--. ||V.--. ||I.--. ||M.--. |]],
    [[| :(): || :/\: || (\/) || :/\: || :(): || (\/) || (\/) |]],
    [[| ()() || :\/: || :\/: || (__) || ()() || :\/: || :\/: |]],
    [[| '--'N|| '--'O|| '--'A|| '--'H|| '--'V|| '--'I|| '--'M|]],
    [[`------'`------'`------'`------'`------'`------'`------']],
  },
  {
    [[ _        _______  _______                   _________ _______]],
    [[( (    /|(  ___  )(  ___  )|\     /||\     /|\__   __/(       )]],
    [[|  \  ( || (   ) || (   ) || )   ( || )   ( |   ) (   | () () |]],
    [[|   \ | || |   | || (___) || (___) || |   | |   | |   | || || |]],
    [[| (\ \) || |   | ||  ___  ||  ___  |( (   ) )   | |   | |(_)| |]],
    [[| | \   || |   | || (   ) || (   ) | \ \_/ /    | |   | |   | |]],
    [[| )  \  || (___) || )   ( || )   ( |  \   /  ___) (___| )   ( |]],
    [[|/    )_)(_______)|/     \||/     \|   \_/   \_______/|/     \|]],
  },
  {
    [[  _  _                    _      __   __    _]],
    [[ | \| |    ___    __ _   | |_    \ \ / /   (_)    _ __]],
    [[ | .` |   / _ \  / _` |  | ' \    \ V /    | |   | '  \]],
    [[ |_|\_|   \___/  \__,_|  |_||_|   _\_/_   _|_|_  |_|_|_|]],
    [[_|"""""|_|"""""|_|"""""|_|"""""|_| """"|_|"""""|_|"""""|]],
    [["`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-']],
  },
  {
    [[,---.   .--.    ,-----.       ____    .---.  .---. ,---.  ,---..-./`) ,---.    ,---.]],
    [[|    \  |  |  .'  .-,  '.   .'  __ `. |   |  |_ _| |   /  |   |\ .-.')|    \  /    |]],
    [[|  ,  \ |  | / ,-.|  \ _ \ /   '  \  \|   |  ( ' ) |  |   |  .'/ `-' \|  ,  \/  ,  |]],
    [[|  |\_ \|  |;  \  '_ /  | :|___|  /  ||   '-(_{;}_)|  | _ |  |  `-'`"`|  |\_   /|  |]],
    [[|  _( )_\  ||  _`,/ \ _/  |   _.-`   ||      (_,_) |  _( )_  |  .---. |  _( )_/ |  |]],
    [[| (_ o _)  |: (  '\_/ \   ;.'   _    || _ _--.   | \ (_ o._) /  |   | | (_ o _) |  |]],
    [[|  (_,_)\  | \ `"/  \  ) / |  _( )_  ||( ' ) |   |  \ (_,_) /   |   | |  (_,_)  |  |]],
    [[|  |    |  |  '. \_/``".'  \ (_ o _) /(_{;}_)|   |   \     /    |   | |  |      |  |]],
    [['--'    '--'    '-----'     '.(_,_).' '(_,_) '---'    `---`     '---' '--'      '--']],
  },
  {
    [[███    ██  ██████   █████  ██   ██ ██    ██ ██ ███    ███]],
    [[████   ██ ██    ██ ██   ██ ██   ██ ██    ██ ██ ████  ████]],
    [[██ ██  ██ ██    ██ ███████ ███████ ██    ██ ██ ██ ████ ██]],
    [[██  ██ ██ ██    ██ ██   ██ ██   ██  ██  ██  ██ ██  ██  ██]],
    [[██   ████  ██████  ██   ██ ██   ██   ████   ██ ██      ██]],
  },
  {
    [[|\| () /\ |-| \/ | |\/|]],
  },
  {
    [[.  .      .  .  .]],
    [[|\ | _  _.|_ \  /*._ _]],
    [[| \|(_)(_][ ) \/ |[ | )]],
  },
  {
    [[     ___           ___           ___           ___                                    ___]],
    [[     /__/\         /  /\         /  /\         /__/\          ___        ___          /__/\]],
    [[     \  \:\       /  /::\       /  /::\        \  \:\        /__/\      /  /\        |  |::\]],
    [[      \  \:\     /  /:/\:\     /  /:/\:\        \__\:\       \  \:\    /  /:/        |  |:|:\]],
    [[  _____\__\:\   /  /:/  \:\   /  /:/~/::\   ___ /  /::\       \  \:\  /__/::\      __|__|:|\:\]],
    [[ /__/::::::::\ /__/:/ \__\:\ /__/:/ /:/\:\ /__/\  /:/\:\  ___  \__\:\ \__\/\:\__  /__/::::| \:\]],
    [[ \  \:\~~\~~\/ \  \:\ /  /:/ \  \:\/:/__\/ \  \:\/:/__\/ /__/\ |  |:|    \  \:\/\ \  \:\~~\__\/]],
    [[  \  \:\  ~~~   \  \:\  /:/   \  \::/       \  \::/      \  \:\|  |:|     \__\::/  \  \:\]],
    [[   \  \:\        \  \:\/:/     \  \:\        \  \:\       \  \:\__|:|     /__/:/    \  \:\]],
    [[    \  \:\        \  \::/       \  \:\        \  \:\       \__\::::/      \__\/      \  \:\]],
    [[     \__\/         \__\/         \__\/         \__\/           ~~~~                   \__\/]],
  },
}

vim.api.nvim_create_autocmd("VimEnter", {
  desc = "Start Alpha when vim is opened with no arguments",
  group = vim.api.nvim_create_augroup("alpha_autostart", { clear = true }),
  callback = function()
    math.randomseed(os.time())
    local random_header = ALPHA_possible_headers[math.random(#ALPHA_possible_headers)]
    require("alpha.themes.dashboard").section.header.val = random_header

    local should_skip
    local lines = vim.api.nvim_buf_get_lines(0, 0, 2, false)
    if
      vim.fn.argc() > 0 -- don't start when opening a file
      or #lines > 1 -- don't open if current buffer has more than 1 line
      or (#lines == 1 and lines[1]:len() > 0) -- don't open the current buffer if it has anything on the first line
      or #vim.tbl_filter(function(bufnr) return vim.bo[bufnr].buflisted end, vim.api.nvim_list_bufs()) > 1 -- don't open if any listed buffers
      or not vim.o.modifiable -- don't open if not modifiable
    then
      should_skip = true
    else
      for _, arg in pairs(vim.v.argv) do
        if arg == "-b" or arg == "-c" or vim.startswith(arg, "+") or arg == "-S" then
          should_skip = true
          break
        end
      end
    end
    if should_skip then
      return
    end

    require("alpha").start(true)

    vim.schedule(function() vim.cmd.doautocmd("FileType") end)
  end,
})

return {
  "goolord/alpha-nvim",
  commit = "8e7a416cfc0c1fa2e607f279053d99041587eb99",
  event = "VimEnter",
  opts = function()
    local dashboard = require("alpha.themes.dashboard")

    dashboard.section.buttons.val = {
      dashboard.button("<LDR> e  ", "  Explorer", "<cmd> NvimTreeToggle <cr>"),
      dashboard.button("<LDR> f f", "  Find file", "<cmd> Telescope find_files <cr>"),
      dashboard.button("<LDR> f o", "  Recently opened files", "<cmd> Telescope oldfiles <cr>"),
      dashboard.button("<LDR> f w", "  Find words", "<cmd> Telescope live_grep <cr>"),
      dashboard.button("<LDR> p l", "󰒲  Lazy plugins", "<cmd> Lazy <cr>"),
      dashboard.button("<LDR> p m", "󱢶  Mason plugins", "<cmd> Mason <cr>"),
      dashboard.button("<LDR> S  ", "  Restore session", [[<cmd> lua require("persistence").load() <cr>]]),
      dashboard.button("<LDR> q  ", "  Quit", "<cmd> qa <cr>"),
    }
    for _, button in ipairs(dashboard.section.buttons.val) do
      button.opts.hl = "AlphaButtons"
      button.opts.hl_shortcut = "AlphaShortcut"
    end
    dashboard.section.header.opts.hl = "AlphaHeader"
    dashboard.section.buttons.opts.hl = "AlphaButtons"
    dashboard.section.footer.opts.hl = "AlphaFooter"
    dashboard.opts.layout[1].val = 8
    return dashboard
  end,

  config = function(_, dashboard)
    -- close Lazy and re-open when the dashboard is ready
    if vim.o.filetype == "lazy" then
      vim.cmd.close()
      vim.api.nvim_create_autocmd("User", {
        once = true,
        pattern = "AlphaReady",
        callback = function() require("lazy").show() end,
      })
    end

    require("alpha").setup(dashboard.opts)

    vim.api.nvim_create_autocmd("User", {
      once = true,
      pattern = "LazyVimStarted",
      callback = function()
        local stats = require("lazy").stats()
        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
        -- dashboard.section.footer.val = "⚡ Loaded "
        --     .. stats.loaded .. "/" .. stats.count .. " plugins in "
        --     .. ms .. "ms"
        dashboard.section.footer.val = "⚡ " .. ms .. "ms"
        pcall(vim.cmd.AlphaRedraw)
      end,
    })
  end,
}
