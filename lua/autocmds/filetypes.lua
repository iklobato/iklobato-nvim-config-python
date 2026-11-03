local group = vim.api.nvim_create_augroup("UserFiletypes", { clear = true })

local BIGFILE_BYTES = 1024 * 1024

local function bigfile_filetype(path, buf)
  -- buf -1: a by-name match (vim.filetype passes -1), the FileType handler below asking
  -- for the real filetype. Not a filetype=="bigfile" check: `:e` re-detects and would flip it.
  if not path or not buf or buf < 0 then
    return nil
  end
  local stats = vim.uv.fs_stat(path)
  if stats and stats.size > BIGFILE_BYTES then
    return "bigfile"
  end
end

-- A >1MB file gets filetype "bigfile": no server, parser or indent guide matches it.
-- Registered on the first read, so an empty start does not load vim.filetype.
vim.api.nvim_create_autocmd("BufReadPre", {
  group = group,
  once = true,
  callback = function()
    vim.filetype.add({ pattern = { [".*"] = { bigfile_filetype, { priority = math.huge } } } })
  end,
})

-- keep it readable: regex syntax of the real filetype, which is cheap on big files
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "bigfile",
  callback = function(args)
    local real = vim.filetype.match({ filename = vim.api.nvim_buf_get_name(args.buf) })
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(args.buf) then
        vim.bo[args.buf].syntax = real or ""
      end
    end)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "json",
  callback = function()
    vim.bo.formatprg = "jq ."
  end,
})
