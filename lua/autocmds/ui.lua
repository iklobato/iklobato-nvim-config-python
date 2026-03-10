-- UI-related autocmds

-- Resize query result output window to 75% of screen
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*.dbout",
  callback = function()
    if vim.bo.filetype == "dbout" then
      local bufnr = vim.api.nvim_get_current_buf()
      vim.defer_fn(function()
        local winid = vim.fn.bufwinid(bufnr)
        if winid and winid > 0 then
          local total_lines = vim.o.lines - 2
          local height = math.max(10, math.floor(total_lines * 0.75))
          pcall(vim.api.nvim_win_set_height, winid, height)
        end
      end, 100)
    end
  end,
})

