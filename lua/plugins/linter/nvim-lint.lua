-- nvim-lint: Linting framework for Neovim
return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    -- Configure linters
    lint.linters_by_ft = {
      -- Add other file types as needed
      -- python = { "pylint" },
      -- javascript = { "eslint" },
      terraform = { "tflint" },
      hcl = { "tflint" },
    }

    -- Auto-lint disabled - removed automatic linting on BufEnter, BufWritePre, and InsertLeave
    -- Keybindings removed - linting tools are available but not bound to shortcuts
  end,
}

