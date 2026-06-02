-- Detect buffers that would freeze nvim when edited. Triggers if EITHER:
--   * any of the first 100 lines exceeds 5000 chars (primary case), OR
--   * file size > 5 MB (safety net for huge files of any shape).
--
-- AIDB's pg_regress fixtures pack byte arrays onto single lines (130K+ chars)
-- inside tiny files, so size-only detection misses them.

local LINE_LENGTH_LIMIT = 5000
local LINES_TO_SAMPLE = 100
local SIZE_LIMIT = 5 * 1024 * 1024
local READ_CHUNK = 1024 * 1024

local function detect(filepath)
  local st = vim.uv.fs_stat(filepath)
  if not st or st.type ~= "file" then
    return nil
  end

  local fd = vim.uv.fs_open(filepath, "r", 438)
  if fd then
    local data = vim.uv.fs_read(fd, math.min(st.size, READ_CHUNK), 0)
    vim.uv.fs_close(fd)
    if data then
      local lineno = 0
      for line in data:gmatch("([^\n]+)") do
        lineno = lineno + 1
        if lineno > LINES_TO_SAMPLE then
          break
        end
        if #line > LINE_LENGTH_LIMIT then
          return string.format("long line (%d chars)", #line)
        end
      end
    end
  end

  if st.size > SIZE_LIMIT then
    return string.format("large file (%.1f MB)", st.size / 1024 / 1024)
  end

  return nil
end

local group = vim.api.nvim_create_augroup("long_lines", { clear = true })

vim.api.nvim_create_autocmd("BufReadPre", {
  group = group,
  callback = function(args)
    if args.file == "" then
      return
    end
    local reason = detect(args.file)
    if reason then
      vim.b[args.buf].long_lines_mode = true
      vim.b[args.buf].long_lines_reason = reason
    end
  end,
})

vim.api.nvim_create_autocmd({ "BufReadPost", "FileType" }, {
  group = group,
  callback = function(args)
    if not vim.b[args.buf].long_lines_mode then
      return
    end

    vim.opt_local.foldmethod = "manual"
    vim.opt_local.spell = false
    vim.opt_local.swapfile = false
    vim.opt_local.undofile = false
    vim.opt_local.wrap = false

    pcall(vim.treesitter.stop, args.buf)
    pcall(function() require("illuminate.engine").stop_buf(args.buf) end)
    pcall(function() require("ibl").setup_buffer(args.buf, { enabled = false }) end)
  end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  group = group,
  callback = function(args)
    if vim.b[args.buf].long_lines_mode and not vim.b[args.buf].long_lines_notified then
      vim.b[args.buf].long_lines_notified = true
      vim.notify("Lite editing mode: " .. (vim.b[args.buf].long_lines_reason or ""), vim.log.levels.WARN, { title = "long-lines" })
    end
  end,
})
