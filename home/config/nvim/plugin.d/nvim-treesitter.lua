local parser_install_dir = vim.fn.stdpath("data") .. "/treesitter"
-- It MUST be at the beginning of runtimepath. Otherwise the parsers from Neovim itself
-- is loaded that may not be compatible with the queries from the 'nvim-treesitter' plugin.
vim.opt.runtimepath:prepend(parser_install_dir)

require('nvim-treesitter.configs').setup {
  parser_install_dir = parser_install_dir,
  modules = {},
  highlight = {
    enable = true,
  },
  indent = {
    enable = false,
  },
  sync_install = false,
  auto_install = true,
  ignore_install = {},
  ensure_installed = {
    "bash",
    "c",
    "cpp",
    "css",
    "go",
    "gomod",
    "graphql",
    "haskell",
    "html",
    "javascript",
    "jsdoc",
    "json",
    "json5",
    "jsonc",
    "llvm",
    "lua",
    "make",
    "markdown",
    "proto",
    "python",
    "regex",
    "rego",
    "rst",
    "rust",
    "scss",
    "terraform",
    "toml",
    "tsx",
    "typescript",
    "vim",
    "vue",
    "yaml",
    "zig",
  }
}
