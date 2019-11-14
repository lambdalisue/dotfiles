setl tabstop=8
setl softtabstop=8
setl shiftwidth=8
setl noexpandtab

function! s:godoc(query) abort
  execute printf('term go doc %s', shellescape(a:query))
endfunction

command! -buffer -nargs=+ GoDoc call s:godoc(<q-args>)

if !exists("*s:goimports")
  function! s:goimports() abort
    if &modified
      return
    endif
    call system(printf("goimports -w %s", shellescape(expand("%"))))
    edit
  endfunction
endif

command! -buffer GoImports call s:goimports()

if executable("goimports")
  autocmd MyAutoCmd BufWritePost *.go call s:goimports()
endif
