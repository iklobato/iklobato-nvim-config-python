return {
    "rmagatti/auto-session",
    config = function()
        require("auto-session").setup({
            log_level = "error",
            auto_session_enable_last_session = false,
            auto_session_root_dir = vim.fn.stdpath("data").."/sessions/",
            auto_session_enabled = true,
            auto_save_enabled = true,
            auto_restore_enabled = true,
            auto_session_use_git_branch = true,
            auto_session_create_enabled = true,
            root_dir = vim.fn.getcwd(),
            -- Add these hooks to ensure proper directory handling
            pre_save_cmds = {
                function()
                    -- Save current directory before saving session
                    vim.g.auto_session_last_dir = vim.fn.getcwd()
                end,
            },
            post_restore_cmds = {
                function()
                    -- Change to the directory where the session was saved
                    if vim.g.auto_session_last_dir then
                        vim.cmd('cd ' .. vim.g.auto_session_last_dir)
                    end
                    -- Reset Telescope and other plugins to use current directory
                    vim.cmd('silent! lcd .')
                end,
            },
        })

        -- Optional: Add a command to manually save session
        vim.api.nvim_create_user_command('SaveSession', function()
            require('auto-session').SaveSession()
        end, {})
    end
}
