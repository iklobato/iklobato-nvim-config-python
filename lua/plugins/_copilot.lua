return {
    'github/copilot.vim',
    event = 'VimEnter',
    config = function()
        vim.g.copilot_no_tab_map = true
        vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
        vim.api.nvim_set_keymap("i", "<Tab>", 'copilot#Accept("<Tab>")', { silent = true, expr = true })
        vim.api.nvim_set_keymap("i", "<S-Tab>", 'copilot#Previous()', { silent = true, expr = true })
    end,
}

