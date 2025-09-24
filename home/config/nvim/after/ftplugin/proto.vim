setl foldmethod=syntax

setl tabstop=8
setl softtabstop=2
setl shiftwidth=2
setl smarttab
setl expandtab

setl autoindent
setl smartindent

" It seems nvim-treesitter overwrites the indentexpr
call timer_start(0, { -> execute('setl indentexpr=""') })
