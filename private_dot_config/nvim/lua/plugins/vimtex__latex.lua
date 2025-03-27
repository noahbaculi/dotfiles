return {
  "lervag/vimtex",
  lazy = false,
  init = function()
    vim.g.vimtex_mappings_enabled = false

    vim.g.vimtex_view_method = "skim"

    vim.g.vimtex_compiler_method = "tectonic"
    vim.g.vimtex_compiler_tectonic = {
      executable = "tectonic",
      options = {
        "--synctex",
        "--keep-logs",
        "--keep-intermediates",
      },
    }

    -- Automatically trigger compile on save
    vim.cmd([[
      augroup vimtex_compile_on_save
        autocmd!
        autocmd BufWritePost *.tex :VimtexCompile
      augroup END
    ]])
  end,
}
