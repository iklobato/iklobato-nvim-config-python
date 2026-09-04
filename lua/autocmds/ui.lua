-- UI-related autocmds
local group = vim.api.nvim_create_augroup("UserUi", { clear = true })

-- Resize query result output window to 75% of screen. No filetype guard: the
-- *.dbout pattern already scopes it, and dadbod-ui sets filetype=dbout from its
-- own BufRead autocmd that runs AFTER this one, so at callback time the filetype
-- is still empty and the guard skipped the resize every time.
vim.api.nvim_create_autocmd("BufReadPost", {
  group = group,
  pattern = "*.dbout",
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    vim.defer_fn(function()
      local winid = vim.fn.bufwinid(bufnr)
      if winid and winid > 0 then
        local total_lines = vim.o.lines - 2
        local height = math.max(10, math.floor(total_lines * 0.75))
        pcall(vim.api.nvim_win_set_height, winid, height)
      end
    end, 100)
  end,
})
