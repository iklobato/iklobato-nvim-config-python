local M = {}

local prettier = { "prettier" }

function M.setup()
  require("conform").setup({
    formatters = {
      stylua = {
        -- stylua's --range-end is the first BYTE OFFSET excluded, but conform's
        -- computed end_offset points AT the last selected byte (matching how
        -- ruff_format/prettier read it), so a linewise visual selection of a
        -- single line left that line unformatted. +1 covers the last byte.
        range_args = function(self, ctx)
          local util = require("conform.util")
          local start_offset, end_offset = util.get_offsets_from_range(ctx.buf, ctx.range)
          return {
            "--search-parent-directories",
            "--respect-ignores",
            "--stdin-filepath",
            "$FILENAME",
            "--range-start",
            tostring(start_offset),
            "--range-end",
            tostring(end_offset + 1),
            "-",
          }
        end,
      },
    },
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "ruff_format" },
      c = { "clang_format" },
      -- these read .prettierrc.json from the project root
      javascript = prettier,
      javascriptreact = prettier,
      typescript = prettier,
      typescriptreact = prettier,
      json = prettier,
      jsonc = prettier,
      css = prettier,
      html = prettier,
      yaml = prettier,
      markdown = prettier,
    },
  })
end

return M
