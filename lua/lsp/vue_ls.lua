return {
    ensure_installed = true,
    filetypes = {'vue'},
    root_dir = function(fname)
        local git_root = vim.fs.find(".git", { path = fname, upward = true })[1]
        if git_root then
            return vim.fs.dirname(git_root)
        end
        local root_markers = { "package.json", "vue.config.js", "vite.config.js", "vite.config.ts", "nuxt.config.js", "nuxt.config.ts" }
        for _, marker in ipairs(root_markers) do
            local found = vim.fs.find(marker, { path = fname, upward = true })[1]
            if found then
                return vim.fs.dirname(found)
            end
        end
        return vim.fn.getcwd()
    end,
}


