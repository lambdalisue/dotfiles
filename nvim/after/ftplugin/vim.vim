if exists('g:loaded_nvim_treesitter')
  setlocal foldmethod=expr
  setlocal foldexpr=nvim_treesitter#foldexpr()
else
  setlocal foldmethod=syntax
endif

let g:vimsyn_folding='af'

setl tabstop=8
setl softtabstop=2
setl shiftwidth=2
setl smarttab
setl expandtab

setl autoindent
setl smartindent
setl keywordprg=:help

imap <buffer><expr> <CR> coc#pum#visible()
      \ ? coc#pum#confirm()
      \ : "\<Plug>(vim-backslash-CR)"
