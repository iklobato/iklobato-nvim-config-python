local M = {}

local prettier = { "prettier" }

function M.setup()
  require("conform").setup({
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
