let g:kanaemi_port = 50123

" Switch Kanaemi to ABC once Insert mode is over.
"
" nvim-aibo leaves Insert mode and enters it again on its own whenever it
" reopens its prompt float (focusing the console, :AiboSend, the end of
" Direct mode), so the switch waits a moment and gives up when Insert mode
" came back.
"
" Direct mode closes the prompt float while in Insert mode, so Insert mode
" ends with the console already current, and keys typed from then on go to
" the tool: the mode is left alone there. Submitting with <C-Enter> also
" lands on the console, but leaves Insert mode in the prompt first, so the
" filetype is looked at when Insert mode ends, not when switching.
let s:delay = 100
let s:timer = -1

function! s:schedule() abort
  call s:cancel()
  if &filetype =~# '^aibo-console'
    return
  endif
  let s:timer = timer_start(s:delay, { -> s:switch() })
endfunction

function! s:cancel() abort
  call timer_stop(s:timer)
  let s:timer = -1
endfunction

function! s:switch() abort
  let s:timer = -1
  if mode() =~# '^[iRt]'
    return
  endif
  silent! call kanaemi#set_mode('abc')
endfunction

augroup kanaemi_abc_on_insert_leave
  autocmd!
  autocmd InsertLeave * call s:schedule()
  autocmd InsertEnter,TermEnter * call s:cancel()
augroup END
