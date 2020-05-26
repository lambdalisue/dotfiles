function! s:grea(bang, query) abort
  let query = empty(a:query) ? input('Grea: ') : a:query
  if empty(query)
    redraw
    return
  endif
  execute printf('Grea%s %s .', a:bang, escape(query, ' '))
endfunction
nnoremap <silent> <Leader>gg :<C-u>call <SID>grea('', '')<CR>

