return {
    'rmagatti/auto-session',
    config = function()
        require('auto-session').setup({
            log_level = "error",
            enabled = true,
            auto_save = true,
            auto_restore = true,
            auto_create = true,
            
            root_dir = vim.fn.stdpath("data") .. "/sessions/",
            auto_restore_last_session = false,
            use_git_branch = true,
            
            cwd_change_handling = {
                restore_upcoming_session = true,
                pre_cwd_changed_hook = nil,
                post_cwd_changed_hook = function()
                    pcall(function()
                        require('nvim-tree.api').tree.reload()
                    end)
                end,
            },
            
            allowed_dirs = nil,
            suppressed_dirs = nil,
            
            bypass_save_filetypes = { "NvimTree" },
            
            pre_save_cmds = {
                function()
                    pcall(function()
                        require('nvim-tree.api').tree.close()
                    end)
                end,
            },
            
            post_restore_cmds = {
                function()
                    pcall(function()
                        require('nvim-tree.api').tree.open()
                    end)
                end,
            },

            -- Add session save hooks to handle multiple windows
            session_lens = {
                load_on_setup = true,
                theme_conf = { border = true },
                previewer = false,
            },
        })

        -- Add keymaps with proper error checking
        local status_ok, session_lens = pcall(require, "auto-session.session-lens")
        if status_ok then
            vim.keymap.set('n', '<leader>ss', function()
                session_lens.search_session()
            end, {desc = 'Search sessions'})
        end

        local auto_session = require('auto-session')
        vim.keymap.set('n', '<leader>sd', function()
            auto_session.DeleteSession()
        end, {desc = 'Delete session'})
    end
}
