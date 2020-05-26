let g:loaded_matchparen = 1
let g:parenmatch = 1
function! s:toggle_vim_parenmatch() abort
  silent! call matchdelete(w:parenmatch)
  let g:parenmatch = g:parenmatch ? 0 : 1
  call parenmatch#update()
endfunction
nnoremap <silent> <Plug>(my-toggle-parenmatch)
      \ :<C-u>call <SID>toggle_vim_parenmatch()<CR>
nmap <C-g>m <Plug>(my-toggle-parenmatch)

