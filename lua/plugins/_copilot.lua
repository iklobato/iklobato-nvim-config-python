return {
    'github/copilot.vim',
    event = 'VimEnter',
    config = function()
        vim.g.copilot_no_tab_map = true
        vim.api.nvim_set_keymap("i", "<Tab>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
        --vim.api.nvim_set_keymap("i", "<A-]>", "<Plug>(copilot-next)", { silent = true })
        --vim.api.nvim_set_keymap("i", "<A-[>", "<Plug>(copilot-previous)", { silent = true })
    end,
}

