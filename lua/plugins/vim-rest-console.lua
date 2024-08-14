-- REST Client
return {
  -- https://github.com/diepm/vim-rest-console
  'diepm/vim-rest-console',
  event = 'VeryLazy',
  config = function ()
    vim.g.vrc_set_default_mapping = 0
    vim.g.vrc_response_default_content_type = 'application/json'
    vim.g.vrc_output_buffer_name = '_OUTPUT.json'
    vim.g.vrc_auto_format_response_patterns = {
      json = 'jq',
    }
  end
}
