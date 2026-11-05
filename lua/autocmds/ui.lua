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

-- flash the yanked text so a copy is visible
vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function()
    vim.hl.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})

-- treesitter-context ships no bottom rule; underline the context edge.
-- reapplied on ColorScheme so a theme reload keeps it.
local function style_context()
  vim.api.nvim_set_hl(0, "TreesitterContextBottom", { underline = true })
  vim.api.nvim_set_hl(0, "TreesitterContextLineNumberBottom", { underline = true })
end
vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = style_context })
style_context()

-- a thin breadcrumb at the top of normal windows: filename + modified flag.
-- empty on nvim-tree/telescope/dapui (non-empty buftype) so they stay clean.
local function winbar()
  if vim.bo.buftype ~= "" then
    return ""
  end
  return "%#WinBar# %f%m "
end
_G.user_winbar = winbar
vim.o.winbar = "%{%v:lua.user_winbar()%}"
