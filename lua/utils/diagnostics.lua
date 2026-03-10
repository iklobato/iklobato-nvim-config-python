local M = {}

-- Helper function to open diagnostic float with focus
function M.open_diagnostic_float_with_focus()
  vim.diagnostic.open_float({
    float = { focusable = true, focus = true },
  })
end

-- Helper function to navigate to next diagnostic
function M.goto_next_diagnostic()
  vim.diagnostic.goto_next()
end

-- Helper function to navigate to previous diagnostic
function M.goto_prev_diagnostic()
  vim.diagnostic.goto_prev()
end

return M