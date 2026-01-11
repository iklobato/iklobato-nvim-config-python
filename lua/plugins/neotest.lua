-- Neotest: Modern test runner for Neovim
return {
  'nvim-neotest/neotest',
  -- Lazy-load on first use via keymaps (defined in keymaps.lua) or commands
  -- The keymaps in keymaps.lua will trigger lazy loading when they call require('neotest')
  cmd = { 'Neotest', 'NeotestSummary', 'NeotestOutput', 'NeotestRun', 'NeotestStop' },
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'antoinemadec/FixCursorHold.nvim',
    'nvim-treesitter/nvim-treesitter',
    'nvim-neotest/neotest-python',
  },
  config = function()
    require('neotest').setup({
      adapters = {
        require('neotest-python')({
          runner = 'pytest',
          python = function()
            return vim.fn.executable('python3') == 1 and 'python3' or 'python'
          end,
        }),
      },
      discovery = {
        enabled = true,
      },
      output = {
        enabled = true,
        open_on_run = false,
      },
      summary = {
        enabled = true,
        follow = true,
        expand_errors = true,
        mappings = {
          expand = { '<CR>', '<2-LeftMouse>' },
          output = 'o',
          short = 'O',
          attach = 'a',
          jumpto = 't',
          stop = 's',
        },
      },
    })
  end,
}
