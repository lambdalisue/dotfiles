function! s:preventer() abort
  try
    return context_filetype#get_filetype() !=# 'vim'
  catch
    return 0
  endtry
endfunction

let g:vim_backslash#preventers = [
      \ funcref('s:preventer'),
      \]
