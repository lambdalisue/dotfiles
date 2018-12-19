setl tabstop=8
setl softtabstop=2
setl shiftwidth=2
setl smarttab
setl expandtab

setl autoindent
setl smartindent
setl foldmethod=indent

" https://github.com/leafgarland/typescript-vim#indenting
setl indentkeys+=0.
setl foldmethod=syntax

" " Find 'node_modules' directory
" function! s:add_node_modules() abort
"   let anchor = simplify(expand('%:p:h'))
"   let node_modules = finddir('node_modules', fnameescape(anchor) . ';')
"   if empty(node_modules)
"     return
"   endif
"   execute printf('setl path+=%s', node_modules)
" endfunction
" call s:add_node_modules()
