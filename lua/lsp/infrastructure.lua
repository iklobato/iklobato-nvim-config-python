-- Infrastructure LSP servers: Terraform, TFLint
return {
  -- Terraform
  {
    name = "terraformls",
    ensure_installed = true,
  },

  -- TFLint (Terraform linter)
  {
    name = "tflint",
    ensure_installed = true,
  },
}