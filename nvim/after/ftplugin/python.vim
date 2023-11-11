if exists('g:loaded_nvim_treesitter')
  setlocal foldmethod=expr
  setlocal foldexpr=nvim_treesitter#foldexpr()
else
  setlocal foldmethod=syntax
endif

setl tabstop=8
setl softtabstop=4
setl shiftwidth=4
setl smarttab
setl expandtab

setl textwidth&
setl colorcolumn&

augroup my-coc-python
  autocmd!
  autocmd BufWrite <buffer> silent! call CocAction('runCommand', 'python.sortImports')
augroup END
