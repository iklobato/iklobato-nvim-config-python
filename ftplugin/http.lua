-- HTTP file specific settings
vim.opt_local.syntax = "on"
vim.opt_local.filetype = "http"

-- Load HTTP syntax highlighting
vim.cmd('runtime! syntax/http.vim')
vim.cmd('syntax enable')

-- Show format help for vim-rest-console
vim.api.nvim_create_user_command('HttpFormatHelp', function()
  local help_text = {
    'vim-rest-console expects this format:',
    '',
    'HTTPS://api.example.com',
    'GET /users',
    'Content-Type: application/json',
    '',
    'Or with separator:',
    '',
    'HTTPS://api.example.com',
    'Content-Type: application/json',
    '--',
    'GET /users',
    '',
    'NOT: GET https://api.example.com/users (REST Client format)',
  }
  vim.notify(table.concat(help_text, '\n'), vim.log.levels.INFO)
end, { desc = 'Show HTTP file format help for vim-rest-console' })

-- Convert REST Client format to vim-rest-console format
vim.api.nvim_create_user_command('HttpConvertFormat', function()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local converted = {}
  local i = 1
  
  while i <= #lines do
    local line = lines[i]
    -- Check if line matches REST Client format: METHOD https://...
    local method, url = line:match('^(%s*)(%u+)%s+(https?://[^%s]+)')
    if method and url then
      -- Convert to vim-rest-console format
      local indent = method
      method = method:match('%S+$') or method
      local host = url:match('(https?://[^/]+)')
      local path = url:match('https?://[^/]+(.*)') or '/'
      
      table.insert(converted, indent .. host:upper())
      table.insert(converted, indent .. method .. ' ' .. path)
      i = i + 1
      
      -- Copy headers and body until next request or separator
      while i <= #lines do
        local next_line = lines[i]
        if next_line:match('^%s*###') or (next_line:match('^%s*$') and i < #lines and lines[i+1]:match('^%s*%u+%s+https?://')) then
          break
        end
        if not next_line:match('^%s*%u+%s+https?://') then
          table.insert(converted, next_line)
        end
        i = i + 1
      end
      table.insert(converted, '')
    else
      table.insert(converted, line)
      i = i + 1
    end
  end
  
  vim.api.nvim_buf_set_lines(0, 0, -1, false, converted)
  vim.notify('Converted REST Client format to vim-rest-console format', vim.log.levels.INFO)
end, { desc = 'Convert REST Client format to vim-rest-console format' })
