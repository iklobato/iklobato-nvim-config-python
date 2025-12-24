-- Auto-completion of bracket/paren/quote pairs
return {
  -- https://github.com/windwp/nvim-autopairs
  'windwp/nvim-autopairs',
  event = "InsertEnter",
  priority = 800, -- High priority: core editing utility
  opts = {
    check_ts = true, -- enable treesitter
    ts_config = {
      lua = { "string" }, -- don't add pairs in lua string treesitter nodes
      javascript = { "template_string" }, -- don't add pairs in javascript template_string
    }
  }
}
