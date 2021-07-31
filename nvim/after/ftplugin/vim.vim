let g:vimsyn_folding='af'

setl tabstop=8
setl softtabstop=2
setl shiftwidth=2
setl smarttab
setl expandtab

setl autoindent
setl smartindent
setl foldmethod=syntax

setl keywordprg=:help

command! Vint cexpr system('vint .')

imap <buffer><expr> <CR> pumvisible() ? "<C-y>" : "\<Plug>(vim-backslash-CR)"
