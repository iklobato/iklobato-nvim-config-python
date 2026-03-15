-- Python-specific tree-sitter highlight customizations
local function setup_python_highlights()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function()
      local ts = vim.treesitter
      local query = ts.query

      local highlight_group = vim.api.nvim_create_augroup("PythonTreesitterHighlights", { clear = true })

      vim.api.nvim_create_autocmd("ColorScheme", {
        group = highlight_group,
        callback = function()
          local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
          local comment = vim.api.nvim_get_hl(0, { name = "Comment" })
          local keyword = vim.api.nvim_get_hl(0, { name = "Keyword" })
          local type = vim.api.nvim_get_hl(0, { name = "Type" })
          local string = vim.api.nvim_get_hl(0, { name = "String" })

          vim.api.nvim_set_hl(0, "@string.documentation.python", { link = "Comment" })
          vim.api.nvim_set_hl(0, "@variable.parameter.python", { fg = type.fg, bold = true })
          vim.api.nvim_set_hl(0, "@function.decorator.python", { fg = keyword.fg, bold = true })
          vim.api.nvim_set_hl(0, "@type.builtin.python", { fg = type.fg, italic = true })
        end,
      })
    end,
  })
end

return {
  setup = setup_python_highlights,
}
