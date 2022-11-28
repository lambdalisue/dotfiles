if exists('g:loaded_nvim_treesitter')
  setlocal foldmethod=expr
  setlocal foldexpr=nvim_treesitter#foldexpr()
else
  setlocal foldmethod=syntax
endif

setl tabstop=8
setl softtabstop=8
setl shiftwidth=8
setl noexpandtab

function! s:insertNewLines() abort
  if search('(', 'c', line('.')) is# 0
    return
  endif
  execute "normal! a\<Return>\<Esc>"
  while search('[,)]', 'c', line('.')) isnot# 0
    if getline(line('.'))[col('.') - 1] ==# ')'
      break
    endif
    execute "normal! a\<Return>\<Esc>"
  endwhile
  if search(')', 'c', line('.')) is# 0
    return
  endif
  execute "normal! i,\<Return>\<Esc>"
endfunction

command! -buffer GoInsertNewLines call s:insertNewLines()
