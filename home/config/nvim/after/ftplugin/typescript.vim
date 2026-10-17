if has('nvim')
  setlocal foldmethod=expr
  setlocal foldexpr=nvim_treesitter#foldexpr()
  setlocal foldmethod=manual
else
  setlocal foldmethod=syntax
endif
setlocal shiftwidth=2
setlocal autoindent
setlocal smartindent

" Automatically indent dot chained method calls
setlocal indentkeys+=0.

command! -buffer Test !NO_COLOR=1 deno test -A %
