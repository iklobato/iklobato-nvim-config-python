return {
    'github/copilot.vim',
    event = 'VimEnter',
    config = function()
        -- Disable copilot's default Tab mapping to avoid conflict with nvim-cmp
        -- nvim-cmp (completion) has priority for Tab key in insert mode
        -- Copilot suggestions can be accepted using default keymaps or manually
        vim.g.copilot_no_tab_map = true
        -- Removed explicit Tab mapping - conflicts with nvim-cmp completion
        -- Use copilot's default keymaps or configure alternative if needed
    end,
}

