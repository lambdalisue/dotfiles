if exists('g:loaded_textobj_hyphen')
  finish
endif

silent! call textobj#user#plugin('hyphen', {
      \ '-': {
      \     '*sfile*': expand('<sfile>:p'),
      \     'select-a': 'a-',  '*select-a-function*': 's:select_a',
      \     'select-i': 'i-',  '*select-i-function*': 's:select_i'
      \   }
      \ })

function! s:select_a() abort
  keepjumps normal! F-
  let end_pos = getpos('.')

  keepjumps normal! f-
  let start_pos = getpos('.')
  return ['v', start_pos, end_pos]
endfunction

" ciao-come-stai

function! s:select_i() abort
  keepjumps normal! T-
  let end_pos = getpos('.')

  keepjumps normal! t-
  let start_pos = getpos('.')

  return ['v', start_pos, end_pos]
endfunction

let g:loaded_textobj_hyphen = 1
