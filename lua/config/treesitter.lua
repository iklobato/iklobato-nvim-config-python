local M = {}

function M.setup()
  require("nvim-treesitter.configs").setup({
    sync_install = false,
    auto_install = true,
    ensure_installed = {
      "lua",
      "python",
      "javascript",
      "typescript",
      "tsx",
      "html",
      "css",
      "json",
      "markdown",
      "markdown_inline",
      "bash",
      "vim",
      "go",
      "rust",
      "ruby",
      "toml",
      "yaml",
      "requirements",
    },
    highlight = {
      enable = true,
      use_languagetree = true,
      disable = function(lang, buf)
        local max_filesize = 1024 * 1024
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        return ok and stats and stats.size > max_filesize
      end,
    },
    indent = {
      enable = true,
      disable = { "python" },
    },
    rainbow = {
      enable = true,
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "gnn",
        node_incremental = "grn",
        scope_incremental = "grc",
        node_decremental = "grm",
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
        },
      },
    },
  })
end

return M
