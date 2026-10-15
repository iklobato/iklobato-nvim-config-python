local M = {}

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
  -- read by lua/autocmds/session.lua to skip opening the tree after a restore
  vim.g.auto_session_restored = false
  require("auto-session").setup({
    auto_save = true,
    auto_restore = true,
    -- else mksession saves NvimTree_1 and it returns as a phantom buffer
    close_filetypes_on_save = { "checkhealth", "NvimTree" },
    pre_save_cmds = { M.drop_missing_buffers },
    session_lens = { load_on_setup = false },
    post_restore_cmds = {
      function()
        vim.g.auto_session_restored = true
      end,
    },
  })
end

return M
