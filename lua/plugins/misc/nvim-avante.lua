return {
  "yetone/avante.nvim",
  build = vim.fn.has("win32") ~= 0
      and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
      or "make",
  event = "VeryLazy",
  version = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-telescope/telescope.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    -- Add safety check for buffer access
    local original_schedule = vim.schedule
    vim.schedule = function(fn)
      original_schedule(function()
        local ok, err = pcall(fn)
        if not ok then
          -- Silently ignore buffer access errors from avante
          if not err:match("Invalid buffer") then
            vim.notify("Error in scheduled function: " .. tostring(err), vim.log.levels.ERROR)
          end
        end
      end)
    end

    require('avante').setup({
      behaviour = {
        auto_set_keymaps = false,
        support_paste_from_clipboard = true,
      },
      mappings = {
        sidebar = {
          -- Tab keybinding removed to keep default Tab behavior
          -- Users can still use <leader>af to switch sidebar focus
        },
      },
    })
  end,
}







