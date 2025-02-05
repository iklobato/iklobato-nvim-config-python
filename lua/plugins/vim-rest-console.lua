return {
  {
    'diepm/vim-rest-console',
    event = 'VeryLazy',
    config = function()
      vim.g.vrc_set_default_mapping = 0
      vim.g.vrc_response_default_content_type = 'application/json'
      vim.g.vrc_output_buffer_name = '_OUTPUT.json'
      vim.g.vrc_auto_format_response_patterns = {
        json = 'jq',
        xml = 'xmllint --format -',
      }
      vim.g.vrc_horizontal_split = 1
      vim.g.vrc_debug = 0
      vim.g.vrc_elasticsearch_support = 1
      vim.g.vrc_curl_opts = {
        ['-i'] = '',
        ['-s'] = '',
        ['-k'] = '',
        ['-L'] = '',
        ['--connect-timeout'] = 10,
        ['--max-time'] = 60,
        ['--ipv4'] = '',
      }
      vim.g.vrc_auto_format_response_enabled = 1
      vim.g.vrc_auto_format_uhex = 1
      vim.g.vrc_keepalt = 1
      vim.g.vrc_allow_get_request_body = 1
      vim.g.vrc_syntax_highlight_response = 1
      vim.g.vrc_split_request_body = 0  -- Changed to 0
      vim.g.vrc_trigger = ''  -- Empty trigger
      vim.g.vrc_body_delimiter = ''  -- Empty delimiter

      vim.api.nvim_create_autocmd("FileType", {
        pattern = {"rest", "http"},
        callback = function()
          vim.keymap.set('n', '<leader>rr', ':call VrcQuery()<CR>', {
            buffer = true,
            desc = "Execute REST request"
          })
        end
      })
      
      vim.api.nvim_create_autocmd("BufWinEnter", {
        pattern = "_OUTPUT.json",
        callback = function()
          vim.opt_local.wrap = false
          vim.opt_local.linebreak = true
          vim.opt_local.breakindent = true
        end
      })
    end,
    ft = {
      'rest',
      'http',
    }
  }
}
