return {
  cmd = { "yaml-language-server", "--stdio" },
  filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab", "yaml.helm-values" },
  root_markers = { ".git" },
  settings = {
    redhat = { telemetry = { enabled = false } },
    yaml = { format = { enable = true } },
  },
  -- The server formats only when told so at runtime, which it never
  -- advertises in its initial capabilities
  on_init = function(client)
    client.server_capabilities.documentFormattingProvider = true
  end,
}
