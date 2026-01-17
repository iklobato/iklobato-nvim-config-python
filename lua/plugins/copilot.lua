return {
    'github/copilot.vim',
    event = 'VimEnter',
    config = function()
        -- Disable copilot's default Tab mapping - we'll handle it in nvim-cmp
        vim.g.copilot_no_tab_map = true
        -- Tab key will be handled by nvim-cmp which checks for copilot first
    end,
}

