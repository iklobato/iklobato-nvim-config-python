local map = vim.keymap.set

-- Copilot: Tab to accept suggestion
map("i", "<Tab>", function()
  if vim.fn.exists("*copilot#Accept") == 1 then
    local ok, copilot_suggestion = pcall(vim.fn["copilot#Accept"])
    if ok and copilot_suggestion and copilot_suggestion ~= "" and type(copilot_suggestion) == "string" then
      vim.api.nvim_feedkeys(copilot_suggestion, "i", false)
      return
    end
  end
  -- Fallback to blink.cmp
  local ok, blink = pcall(require, "blink.cmp")
  if ok and blink.is_menu_visible and blink.is_menu_visible() then
    blink.accept()
  else
    vim.api.nvim_replace_termcodes("<Tab>", true, false, true)
  end
end, { expr = true, desc = "Copilot accept / blink.cmp accept / Tab" })
