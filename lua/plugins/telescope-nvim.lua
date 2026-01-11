-- Fuzzy finder
-- Cache find_command detection to avoid checking on every call
local cached_find_command = nil
local function get_find_command()
  if cached_find_command then
    return cached_find_command
  end
  -- Check executables once and cache the result
  if vim.fn.executable('fd') == 1 then
    cached_find_command = { 'fd', '--type', 'f', '--hidden', '--follow', '--exclude', '.git', '--exclude', 'node_modules' }
  elseif vim.fn.executable('find') == 1 then
    cached_find_command = { 'find', '.', '-type', 'f', '-not', '-path', '*/.git/*', '-not', '-path', '*/node_modules/*' }
  else
    cached_find_command = nil  -- Use Telescope's built-in Lua finder
  end
  return cached_find_command
end
return {
  'nvim-telescope/telescope.nvim',
  -- Lazy-load on first use via keymaps (defined in keymaps.lua) or commands
  -- The keymaps in keymaps.lua will trigger lazy loading when they call require('telescope.builtin')
  cmd = { 'Telescope' },
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
  opts = function()
    return {
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
      preview = {
        -- Enable line numbers in preview window
        treesitter = { enable = true },
      },
    },
    pickers = {
      find_files = {
        hidden = true,     -- Show hidden files
        no_ignore = false, -- Do respect .gitignore by default
        follow = true,     -- Follow symlinks
        -- Use cached find_command detection
        find_command = get_find_command(),
        file_ignore_patterns = {
          ".git/",
          "node_modules/"
        }
      },
      live_grep = {
        additional_args = function()
          return {
            "--hidden",      -- Search hidden files
            "--no-ignore",   -- Override .gitignore for live grep
            "--glob=!.git/*" -- But still ignore .git directory
          }
        end
      }
    }
    }
  end
}
