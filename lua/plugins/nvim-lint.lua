-- nvim-lint: Linting framework for Neovim
return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")
    -- Configure linters
    lint.linters_by_ft = {
      -- Lua linter
      lua = { "luacheck" },
      -- Add other file types as needed
      -- python = { "pylint" },
      -- javascript = { "eslint" },
      terraform = { "tflint" },
      hcl = { "tflint" },
      -- C/C++ linters
      c = { "clang_tidy", "cppcheck" },
      cpp = { "clang_tidy", "cppcheck" },
      objc = { "clang_tidy" },
      objcpp = { "clang_tidy" },
    }
    -- Auto-lint disabled - removed automatic linting on BufEnter, BufWritePre, and InsertLeave
    -- Keybindings removed - linting tools are available but not bound to shortcuts
  end,
}
