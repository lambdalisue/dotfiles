" Smart fold navigation for h/l keys
" l - open fold at cursor if cursor is on closed fold, otherwise normal l
" h - close fold at cursor if cursor is in open fold at column 1, otherwise normal h

function! s:smart_l() abort
  if foldclosed('.') != -1
    " Cursor is on a closed fold, open it
    return "zv"
  else
    " Normal l behavior
    return "l"
  endif
endfunction

function! s:smart_h() abort
  if foldlevel('.') > 0 && foldclosed('.') == -1 && col('.') == 1
    " Cursor is in an open fold at column 1, close it one level
    return "zc"
  else
    " Normal h behavior
    return "h"
  endif
endfunction

nnoremap <silent><expr> l <SID>smart_l()
nnoremap <silent><expr> h <SID>smart_h()
