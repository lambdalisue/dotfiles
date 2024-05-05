setlocal foldmethod=syntax

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
