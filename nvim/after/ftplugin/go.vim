setl tabstop=8
setl softtabstop=8
setl shiftwidth=8
setl noexpandtab

function! s:godoc(query) abort
  execute printf('term go doc %s', shellescape(a:query))
endfunction

command! -buffer -nargs=+ GoDoc call s:godoc(<q-args>)
