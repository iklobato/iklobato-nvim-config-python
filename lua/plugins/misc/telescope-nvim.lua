-- Fuzzy finder
return {
  'nvim-telescope/telescope.nvim',
  lazy = true,
  dependencies = {
    { 'nvim-lua/plenary.nvim' },
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
  },
  opts = {
    defaults = {
      layout_config = {
        vertical = {
          width = 0.75
        }
      },
      path_display = {
        filename_first = {
          reverse_directories = true
        }
      },
      file_ignore_patterns = {
        ".git/",
        "node_modules/"
      },
      vimgrep_arguments = {
        'rg',
        '--color=never',
        '--no-heading',
        '--with-filename',
        '--line-number',
        '--column',
        '--smart-case',
        '--no-ignore',     -- Don't respect .gitignore
        '--hidden',        -- Search hidden files
        '--glob=!.git/*'   -- But still ignore .git directory
      },
    },
    pickers = {
      find_files = {
        hidden = true,     -- Show hidden files
        no_ignore = false, -- Do respect .gitignore by default
        file_ignore_patterns = {
          ".git/",
          "node_modules/"
        }
      },
      live_grep = {
        additional_args = function()
          return {
            "--hidden",      -- Search hidden files
            "--glob=!.git/*" -- But still ignore .git directory
          }
        end
      }
    }
  }
}
