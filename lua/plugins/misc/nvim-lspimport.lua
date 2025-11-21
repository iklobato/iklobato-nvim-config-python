-- Auto-import plugin for better import resolution
-- Uses LSP completion API to find and insert correct import statements
return {
  "stevanmilic/nvim-lspimport",
  event = "LspAttach",
  config = function()
    -- Configure keybinding for auto-import
    -- Place cursor on undefined symbol and press <leader>ai to import it
    vim.keymap.set("n", "<leader>ai", require("lspimport").import, {
      desc = "Auto-import symbol under cursor",
      noremap = true,
      silent = true,
    })
    
    -- Also works in insert mode
    vim.keymap.set("i", "<C-i>", function()
      require("lspimport").import()
    end, {
      desc = "Auto-import symbol under cursor",
      noremap = true,
      silent = true,
    })
  end,
}

