local group = vim.api.nvim_create_augroup("ExternalReload", { clear = true })
local BACKUP_DIR = vim.fn.stdpath("state") .. "/unsaved"

-- check the disk when coming back from Claude/terminal, not only on the next shell cmd
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "TermLeave" }, {
  group = group,
  callback = function()
    if vim.fn.getcmdwintype() == "" then
      vim.cmd("checktime")
    end
  end,
})

local function backup_path(buf)
  local full = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":p")
  return string.format("%s/%s.%s", BACKUP_DIR, (full:gsub("/", "%%")), os.date("%Y%m%d-%H%M%S"))
end

vim.api.nvim_create_autocmd("FileChangedShell", {
  group = group,
  callback = function(args)
    if vim.v.fcs_reason == "deleted" then
      vim.v.fcs_choice = "" -- file gone: keep the buffer as is
      vim.notify("file deleted on disk, buffer kept", vim.log.levels.WARN)
      return
    end
    if vim.bo[args.buf].modified then
      vim.fn.mkdir(BACKUP_DIR, "p")
      local path = backup_path(args.buf)
      if vim.fn.writefile(vim.api.nvim_buf_get_lines(args.buf, 0, -1, false), path) ~= 0 then
        vim.v.fcs_choice = "ask" -- backup failed: never reload over unsaved text
        return
      end
      vim.notify(
        "unsaved changes saved to " .. path .. " (u also restores them)",
        vim.log.levels.WARN
      )
    end
    vim.v.fcs_choice = "reload"
  end,
})
