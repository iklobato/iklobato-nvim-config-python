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

    -- Auto-lint before save (runs before formatting) and when opening files
    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePre", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        lint.try_lint()
      end,
    })

    -- Keybindings for manual linting and fixing
    vim.keymap.set("n", "<leader>ll", function()
      lint.try_lint()
    end, { desc = "Lint buffer" })

    -- Auto-fix using selene (if available)
    vim.keymap.set("n", "<leader>lf", function()
      local bufnr = vim.api.nvim_get_current_buf()
      local filetype = vim.bo[bufnr].filetype

      if filetype == "lua" then
        -- Try to auto-fix with selene
        vim.cmd("silent !selene --fix " .. vim.fn.shellescape(vim.api.nvim_buf_get_name(bufnr)))
        vim.cmd("edit") -- Reload the file
        lint.try_lint() -- Re-lint after fixing
      else
        vim.notify("Auto-fix not available for filetype: " .. filetype, vim.log.levels.WARN)
      end
    end, { desc = "Auto-fix linting issues" })
  end,
}

