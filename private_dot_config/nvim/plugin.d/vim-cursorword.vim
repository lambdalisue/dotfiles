let g:cursorword = 1

function! s:toggle_vim_cursorword() abort
  let g:cursorword = g:cursorword ? 0 : 1
  call cursorword#matchadd()
  echo g:cursorword
        \ ? 'enabled'
        \ : 'disabled'
endfunction
command! -nargs=0 CursorwordToggle call s:toggle_vim_cursorword()
