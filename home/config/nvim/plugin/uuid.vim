" Insert UUID by <F2>
function! s:uuid() abort
  let r = system('uuidgen')
  let r = substitute(r, '^[\r\n\s]*\|[\r\n\s]*$', '', 'g')
  return r
endfunction
inoremap <silent> <Plug>(my-insert-uuid) <C-r>=<SID>uuid()<CR>
imap <F2> <Plug>(my-insert-uuid)
