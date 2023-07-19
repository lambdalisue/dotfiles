local parser_install_dir = vim.fn.stdpath("data") .. "/treesitter"
vim.opt.runtimepath:append(parser_install_dir)

require('nvim-treesitter.configs').setup {
  parser_install_dir = parser_install_dir,
  highlight = {
    enable = true,
  },
  indent = {
    enable = true,
  },
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
    "python",
    "regex",
    "rego",
    "rst",
    "rust",
    "scss",
    "toml",
    "typescript",
    "terraform",
    "vim",
    "vue",
    "yaml",
    "zig",
  }
}
