-- nvim-lint: Linting framework for Neovim
-- Configured with selene for Lua linting with auto-fix support
return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    -- Configure linters
    lint.linters_by_ft = {
      lua = { "selene" },
      -- Add other file types as needed
      -- python = { "pylint" },
      -- javascript = { "eslint" },
      terraform = { "tflint" },
      hcl = { "tflint" },
    }

    -- Selene configuration for Lua
    lint.linters.selene = {
      cmd = "selene",
      stdin = true,
      args = { "--display-style", "json", "-" },
      stream = "stdout",
      ignore_exitcode = true,
      parser = function(output, bufnr)
        local diagnostics = {}
        local decoded = vim.json.decode(output)

        if decoded and decoded.diagnostics then
          for _, diagnostic in ipairs(decoded.diagnostics) do
            table.insert(diagnostics, {
              lnum = diagnostic.line - 1, -- 0-indexed
              col = diagnostic.column - 1, -- 0-indexed
              end_lnum = diagnostic.end_line and (diagnostic.end_line - 1) or diagnostic.line - 1,
              end_col = diagnostic.end_column and (diagnostic.end_column - 1) or diagnostic.column - 1,
              severity = vim.diagnostic.severity.WARN,
              source = "selene",
              message = diagnostic.message,
              code = diagnostic.code,
            })
          end
        end

        return diagnostics
      end,
    }

    -- Auto-lint disabled - removed automatic linting on BufEnter, BufWritePre, and InsertLeave
    -- Keybindings removed - linting tools are available but not bound to shortcuts
  end,
}

