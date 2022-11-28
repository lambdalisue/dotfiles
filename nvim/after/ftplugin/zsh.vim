if exists('g:loaded_nvim_treesitter')
  setlocal foldmethod=expr
  setlocal foldexpr=nvim_treesitter#foldexpr()
else
  setlocal foldmethod=syntax
endif

setlocal shiftwidth=2

