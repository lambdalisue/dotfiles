-- root_dir lives in plugin.d/lsp.lua, which splits buffers between this
-- server and denols
return {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  init_options = { hostInfo = "neovim" },
}
