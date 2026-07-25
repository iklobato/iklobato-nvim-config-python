local M = {}

function M.setup()
  -- jsonc grammar's upstream renamed default branch master -> main; pin it so install works
  require("nvim-treesitter.parsers").get_parser_configs().jsonc.install_info.revision = "main"

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
      "http",
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
      "dockerfile",
      "make",
      "tmux",
    },
    highlight = {
      enable = true,
      disable = function(lang, buf)
        local max_filesize = 1024 * 1024
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
        return ok and stats and stats.size > max_filesize
      end,
    },
    indent = {
      enable = true,
      disable = { "python" },
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
