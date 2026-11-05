local M = {}

function M.setup()
  local telescope = require("telescope")
  telescope.setup({
    defaults = {
      -- prompt_prefix stays the default "> ": tests/e2e.sh asserts "> app" to prove the
      -- prompt itself rendered (the bufferline tab would pass a bare "app" match)
      selection_caret = "❯ ",
      entry_prefix = "  ",
      winblend = 10,
      borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      -- matched unanchored: a bare "build" would also hide builder.py
      file_ignore_patterns = {
        "^node_modules/",
        "/node_modules/",
        "^%.git/",
        "/%.git/",
        "^dist/",
        "/dist/",
        "^build/",
        "/build/",
        "^__pycache__/",
        "/__pycache__/",
        "%.pyc$",
      },
    },
  })
end

return M
