return {
  {
    "rest-nvim/rest.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    -- Load eagerly to ensure commands are available
    lazy = false,
    config = function()
      -- Register the tree-sitter-http parser with the correct path
      vim.treesitter.language.add("http", {
        path = vim.fn.stdpath("data") .. "/lazy-rocks/rest.nvim/lib/lua/5.1/parser/http.so"
      })

      -- Configure rest-nvim with custom settings
      require("rest-nvim").setup({
        -- Keep horizontal split configuration enabled (this is the only custom setting)
        result_split_horizontal = true,
        -- Disable highlight to prevent tree-sitter issues during session restore
        highlight = {
          enabled = false,
        },
        -- Use all other default settings
      })
    end,
  }
}