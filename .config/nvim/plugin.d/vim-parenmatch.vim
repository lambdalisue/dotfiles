let g:loaded_matchparen = 1
let g:parenmatch = 1

function! s:toggle_vim_parenmatch() abort
  silent! call matchdelete(w:parenmatch)
  let g:parenmatch = g:parenmatch ? 0 : 1
  call parenmatch#update()
  echo g:parenmatch
        \ ? 'enabled'
        \ : 'disabled'
endfunction
command! -nargs=0 ParenmatchToggle call s:toggle_vim_parenmatch()
