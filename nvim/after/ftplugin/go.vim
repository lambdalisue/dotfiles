setl tabstop=8
setl softtabstop=8
setl shiftwidth=8
setl noexpandtab

if has('nvim')
  setlocal foldmethod=expr
  setlocal foldexpr=nvim_treesitter#foldexpr()
else
  setlocal foldmethod=syntax
endif
