return {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  -- Cargo.lock sits at the workspace root, so every crate of a workspace
  -- shares one server instead of one per Cargo.toml
  root_markers = { "Cargo.lock", "rust-project.json", "Cargo.toml", ".git" },
  capabilities = {
    experimental = { serverStatusNotification = true },
  },
  -- rust-analyzer reads some settings (cargo.*) only at startup
  before_init = function(params, config)
    local settings = vim.tbl_get(config, "settings", "rust-analyzer")
    if settings then
      params.initializationOptions = settings
    end
  end,
}
