local group = vim.api.nvim_create_augroup("UserUi", { clear = true })

-- no filetype guard: dadbod-ui sets ft=dbout after this runs, so it is still empty
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
