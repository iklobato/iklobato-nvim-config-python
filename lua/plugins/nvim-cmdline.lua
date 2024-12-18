-- lua/plugins/fine-cmdline.lua
return {
  'VonHeikemen/fine-cmdline.nvim',
  dependencies = {
    'MunifTanjim/nui.nvim'
  },
  config = function()
    require('fine-cmdline').setup({
      cmdline = {
        enable_keymaps = true,
        smart_history = true,
        prompt = ': '
      },
      popup = {
        position = {
          row = '20%',
          col = '70%',
        },
        size = {
          width = '80%',
        },
        border = {
          style = 'rounded',
        },
        win_options = {
          winhighlight = 'Normal:Normal,FloatBorder:FloatBorder',
        },
      }
    })

    -- Replace default command line with fine-cmdline
    vim.api.nvim_set_keymap('n', ':', '<cmd>FineCmdline<CR>', {noremap = true})
    
    -- Optional: If you want to use it in visual mode without the range
    vim.api.nvim_set_keymap('x', ':', '<C-u><cmd>FineCmdline<CR>', {noremap = true})
  end
}

