local M = {}

function M.setup()
  local telescope = require("telescope")
  telescope.setup({
    defaults = {
      -- prompt_prefix stays the default "> ": tests/e2e.sh asserts "> app" to prove the
      -- prompt itself rendered (the bufferline tab would pass a bare "app" match)
      -- the preview would print an env file in clear text, undoing config.cloak
      buffer_previewer_maker = function(filepath, bufnr, opts)
        if require("config.cloak").is_secret_file(filepath) then
          return require("telescope.previewers.utils").set_preview_message(
            bufnr,
            opts.winid,
            "secret file: preview hidden"
          )
        end
        require("telescope.previewers").buffer_previewer_maker(filepath, bufnr, opts)
      end,
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
  telescope.load_extension("fzf")
end

return M
