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
  -- Keys are defined in lua/config/keymaps.lua, so we don't need lazy-loading here
  -- This ensures telescope is always available when keymaps are called
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
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')
    
    -- Custom action to navigate to existing buffer or open new file
    local function smart_file_select(prompt_bufnr)
      local picker = action_state.get_current_picker(prompt_bufnr)
      local entry = action_state.get_selected_entry()
      
      if not entry then
        return
      end
      
      local filename = entry.path or entry.value
      if not filename then
        return
      end
      
      -- Get absolute path
      local abs_path = vim.fn.fnamemodify(filename, ':p')
      
      -- Check if file is already open in a buffer
      local target_bufnr = nil
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) then
          local buf_name = vim.api.nvim_buf_get_name(buf)
          if buf_name ~= '' and vim.fn.fnamemodify(buf_name, ':p') == abs_path then
            target_bufnr = buf
            break
          end
        end
      end
      
      -- If buffer exists, find window containing it and navigate there
      if target_bufnr then
        -- Check all tabs and windows
        local target_win = nil
        local target_tab = nil
        
        for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
            if vim.api.nvim_win_get_buf(win) == target_bufnr then
              target_win = win
              target_tab = tab
              break
            end
          end
          if target_win then
            break
          end
        end
        
        -- Navigate to the window/tab containing the buffer
        if target_win and target_tab then
          -- Close telescope before navigating to avoid picker context issues
          -- Only close if picker is valid (fixes issue with buffers picker)
          if picker then
            actions.close(prompt_bufnr)
            -- Use vim.schedule to ensure close completes before navigation
            vim.schedule(function()
              vim.api.nvim_set_current_tabpage(target_tab)
              vim.api.nvim_set_current_win(target_win)
            end)
          else
            -- If picker is nil, navigate directly and let telescope cleanup handle it
            -- This can happen with certain pickers like buffers
            vim.api.nvim_set_current_tabpage(target_tab)
            vim.api.nvim_set_current_win(target_win)
            -- Try to close the prompt buffer if it's still valid
            if vim.api.nvim_buf_is_valid(prompt_bufnr) then
              pcall(function()
                local win = vim.fn.bufwinid(prompt_bufnr)
                if win ~= -1 and vim.api.nvim_win_is_valid(win) then
                  vim.api.nvim_win_close(win, true)
                end
              end)
            end
          end
          return
        end
      end
      
      -- If not found, open file normally
      actions.select_default(prompt_bufnr)
    end
    
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
      mappings = {
        i = {
          ['<CR>'] = smart_file_select,
        },
        n = {
          ['<CR>'] = smart_file_select,
        },
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
