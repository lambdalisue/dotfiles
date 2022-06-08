let g:vimsyn_folding='af'

setl tabstop=8
setl softtabstop=2
setl shiftwidth=2
setl smarttab
setl expandtab

setl autoindent
setl smartindent
if has('nvim')
  setl foldmethod=expr
  setl foldexpr=nvim_treesitter#foldexpr()
else
  setl foldmethod=syntax
endif

setl keywordprg=:help

imap <buffer><expr> <CR> pumvisible()
      \ ? "<C-y>"
      \ : "\<Plug>(vim-backslash-CR)"
