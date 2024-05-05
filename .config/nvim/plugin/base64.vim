" Yank Base64 encoded/decoded text of the selected text
function! s:encode_base64() abort
  normal! gvy
  let @@ = system('base64', @@)
  let @@ = substitute(@@, '^[\r\n\s]*\|[\r\n\s]*$', '', 'g')
  normal! gvp
endfunction
function! s:decode_base64() abort
  normal! gvy
  let @@ = system('base64 -d', @@)
  let @@ = substitute(@@, '^[\r\n\s]*\|[\r\n\s]*$', '', 'g')
  normal! gvp
endfunction
vnoremap <silent> <Plug>(my-decode-base64) :call <SID>encode_base64()<CR>
vnoremap <silent> <Plug>(my-encode-base64) :call <SID>decode_base64()<CR>
vmap <F3> <Plug>(my-decode-base64)
vmap <F4> <Plug>(my-encode-base64)

