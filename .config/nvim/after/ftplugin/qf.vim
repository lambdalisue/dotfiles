setlocal cursorline
setlocal nospell
setlocal nolist

" Close with q
nnoremap <buffer> q :<C-u>close<CR>

nnoremap <buffer><silent> <C-j> :<C-u>call <SID>older()<CR>
nnoremap <buffer><silent> <C-k> :<C-u>call <SID>newer()<CR>

function! s:is_quickfix()  abort
  return getwininfo(win_getid())[0].quickfix
endfunction

if !exists('*s:older')
  function! s:older() abort
    try
      if s:is_quickfix()
        colder
      else
        lolder
      endif
    catch
      echohl ErrorMsg
      echo substitute(v:exception, 'Vim(.*):', '', '')
      echohl None
    endtry
  endfunction
endif

if !exists('*s:newer')
  function! s:newer() abort
    try
      if s:is_quickfix()
        cnewer
      else
        lnewer
      endif
    catch
      echohl ErrorMsg
      echo substitute(v:exception, 'Vim(.*):', '', '')
      echohl None
    endtry
  endfunction
endif
