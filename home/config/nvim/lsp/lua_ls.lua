return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = {
    { ".luarc.json", ".luarc.jsonc", ".emmyrc.json" },
    { ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".luacheckrc" },
    ".git",
  },
}
