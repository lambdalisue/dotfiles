setl tabstop=8
setl softtabstop=2
setl shiftwidth=2
setl smarttab
setl expandtab

setl autoindent
setl smartindent

" https://github.com/leafgarland/typescript-vim#indenting
setl indentkeys+=0.
setl foldmethod=syntax

" https://github.com/leafgarland/typescript-vim#indenting
let g:typescript_opfirst='\%([<>=,?^%|*/&]\|\([-:+]\)\1\@!\|!=\|in\%(stanceof\)\=\>\)'

" " Find 'node_modules' directory
" function! s:add_node_modules() abort
"   let anchor = simplify(expand('%:p:h'))
"   let node_modules = finddir('node_modules', fnameescape(anchor) . ';')
"   if empty(node_modules)
"     return
"   endif
"   execute printf('setl path+=%s', fnamemodify(node_modules, ':p'))
" endfunction
" call s:add_node_modules()
