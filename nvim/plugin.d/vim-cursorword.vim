let g:cursorword = 1
function! s:toggle_vim_cursorword() abort
  let g:cursorword = g:cursorword ? 0 : 1
  call cursorword#matchadd()
endfunction
nnoremap <silent> <Plug>(my-toggle-cursorword)
      \ :<C-u>call <SID>toggle_vim_cursorword()<CR>
nmap <C-g>c     <Plug>(my-toggle-cursorword)

