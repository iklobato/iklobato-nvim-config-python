local function apply_python_highlights()
  local keyword = vim.api.nvim_get_hl(0, { name = "Keyword" })
  local type_hl = vim.api.nvim_get_hl(0, { name = "Type" })
  vim.api.nvim_set_hl(0, "@string.documentation.python", { link = "Comment" })
  vim.api.nvim_set_hl(0, "@variable.parameter.python", { fg = type_hl.fg, bold = true })
  vim.api.nvim_set_hl(0, "@function.decorator.python", { fg = keyword.fg, bold = true })
  vim.api.nvim_set_hl(0, "@type.builtin.python", { fg = type_hl.fg, italic = true })
end

local function setup_python_highlights()
  local group = vim.api.nvim_create_augroup("PythonTreesitterHighlights", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = apply_python_highlights,
  })
  apply_python_highlights()
end

return {
  setup = setup_python_highlights,
}
