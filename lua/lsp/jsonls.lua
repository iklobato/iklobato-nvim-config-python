return {
    ensure_installed = true,
    settings = {
        json = {
            -- Use schemastore if available, otherwise use basic validation
            schemas = pcall(require, 'schemastore') and require('schemastore').json.schemas() or {},
            validate = { enable = true },
        },
    },
    commands = {
        Format = {
            function()
                vim.lsp.buf.range_formatting({}, {0, 0}, {vim.fn.line("$"), 0})
            end
        }
    }
}