local M = {}

-- A session is written on every exit and read back on the next one, so anything
-- wrong in it survives forever. Buffers whose file was renamed or deleted keep
-- getting re-saved and come back as dead tabs in the bufferline.
function M.drop_missing_buffers()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(buf)
    local is_file_buffer = vim.bo[buf].buftype == "" and name ~= ""
    local exists = vim.fn.filereadable(name) == 1 or vim.fn.isdirectory(name) == 1
    if vim.bo[buf].buflisted and is_file_buffer and not exists and not vim.bo[buf].modified then
      pcall(vim.api.nvim_buf_delete, buf, { force = false })
    end
  end
end

function M.setup()
  -- Tracked so lua/autocmds/session.lua knows whether a restore actually
  -- happened this run, instead of guessing from whether a session FILE exists
  -- for the cwd: that file can exist while nothing was restored (headless runs
  -- skip restoring outright; auto_restore/allowed_dirs can decline it too).
  vim.g.auto_session_restored = false
  require("auto-session").setup({
    auto_save = true,
    auto_restore = true,
    -- otherwise mksession writes `badd NvimTree_1` and the session comes
    -- back with a phantom buffer in the bufferline
    close_filetypes_on_save = { "checkhealth", "NvimTree" },
    pre_save_cmds = { M.drop_missing_buffers },
    -- don't pull the telescope picker in at startup; it loads on :SessionSearch
    session_lens = { load_on_setup = false },
    post_restore_cmds = {
      function()
        vim.g.auto_session_restored = true
      end,
    },
  })
end

return M
