-- Web development LSP servers: JavaScript, TypeScript, Vue, HTML, CSS
return {
  -- TypeScript/JavaScript/Vue
  {
    name = "tsserver",
    ensure_installed = true,
    filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx", "vue" },
    root_dir = function(fname)
      -- Handle buffer number (convert to file path) or file path string
      local path = fname
      if type(fname) == "number" then
        path = vim.api.nvim_buf_get_name(fname)
        if path == "" then
          return vim.fn.getcwd()
        end
      end
      -- Get directory of the file
      local dir = vim.fs.dirname(path)
      local git_root = vim.fs.find(".git", { path = dir, upward = true })[1]
      if git_root then
        return vim.fs.dirname(git_root)
      end
      local root_markers = { "package.json", "tsconfig.json", "jsconfig.json" }
      for _, marker in ipairs(root_markers) do
        local found = vim.fs.find(marker, { path = dir, upward = true })[1]
        if found then
          return vim.fs.dirname(found)
        end
      end
      return vim.fn.getcwd()
    end,
    init_options = {
      plugins = {
        {
          name = "@vue/typescript-plugin",
          location = vim.fn.stdpath("data") .. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
          languages = { "vue" },
        },
      },
    },
    settings = {
      javascript = {
        inlayHints = {
          includeInlayEnumMemberValueHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayParameterNameHints = "all",
          includeInlayParameterNameHintsWhenArgumentMatchesName = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayVariableTypeHints = true,
        },
      },
      typescript = {
        inlayHints = {
          includeInlayEnumMemberValueHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayParameterNameHints = "all",
          includeInlayParameterNameHintsWhenArgumentMatchesName = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayVariableTypeHints = true,
        },
      },
      vue = {
        inlayHints = {
          includeInlayEnumMemberValueHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayParameterNameHints = "all",
          includeInlayParameterNameHintsWhenArgumentMatchesName = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayVariableTypeHints = true,
        },
      },
    },
  },

  -- ESLint
  {
    name = "eslint",
    ensure_installed = true,
  },

  -- HTML
  {
    name = "html",
    ensure_installed = true,
  },

  -- CSS
  {
    name = "cssls",
    ensure_installed = true,
  },

  -- Emmet (HTML/CSS snippets)
  {
    name = "emmet_ls",
    ensure_installed = true,
  },

  -- Tailwind CSS
  {
    name = "tailwindcss",
    ensure_installed = true,
  },

  -- Vue
  {
    name = "vue_ls",
    ensure_installed = true,
  },
}