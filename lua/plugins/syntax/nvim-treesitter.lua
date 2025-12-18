-- Code Tree Support / Syntax Highlighting
return {
  -- https://github.com/nvim-treesitter/nvim-treesitter
  'nvim-treesitter/nvim-treesitter',
  event = 'VeryLazy',
  priority = 600, -- Medium-high priority: syntax highlighting
  dependencies = {
    -- https://github.com/nvim-treesitter/nvim-treesitter-textobjects
    'nvim-treesitter/nvim-treesitter-textobjects',
  },
  build = ':TSUpdate',
  opts = {
    indent = { enable = true },
    highlight = { enable = true },
    auto_install = false, -- Disabled for performance - install parsers manually with :TSInstall
    ensure_installed = {
      'lua',
      'dockerfile',
      'javascript',
      'typescript',
      'tsx',
      'html',
      'css',
      'scss',
      'python',
      'markdown',
      'json',
      'yaml',
      'bash',
      'vim',
      'xml',
      'csv',
      'hcl'
    },
    -- Textobjects configuration - lazy loaded for performance
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          -- Only enable essential textobjects to reduce overhead
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
      },
      move = {
        enable = true,
        set_jumps = true,
        goto_next_start = {
          [']m'] = '@function.outer',
          [']]'] = '@class.outer',
        },
        goto_next_end = {
          [']M'] = '@function.outer',
          [']['] = '@class.outer',
        },
        goto_previous_start = {
          ['[m'] = '@function.outer',
          ['[['] = '@class.outer',
        },
        goto_previous_end = {
          ['[M'] = '@function.outer',
          ['[]'] = '@class.outer',
        },
      },
    },
  },
  config = function (_, opts)
    local configs = require("nvim-treesitter.configs")
    configs.setup(opts)
    vim.api.nvim_create_autocmd({ "FileType" }, {
      pattern = { "typescript", "typescriptreact", "typescript.tsx" },
      callback = function()
        -- Disable Vim syntax to let Treesitter handle it completely
        vim.bo.syntax = "OFF"
      end,
    })
  end
}

