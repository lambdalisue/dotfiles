require('nvim-treesitter').setup({})

-- Enable highlight on FileType autocmd
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("vim-treesitter-start", {}),
  callback = function(_ctx)
    pcall(vim.treesitter.start)
  end
})
