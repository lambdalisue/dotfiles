if exists('g:loaded_textobj_underscore')
  finish
endif

silent! call textobj#user#plugin('underscore', {
      \ '-': {
      \     '*sfile*': expand('<sfile>:p'),
      \     'select-a': 'a_',  '*select-a-function*': 's:select_a',
      \     'select-i': 'i_',  '*select-i-function*': 's:select_i'
      \   }
      \ })

function! s:select_a() abort
  keepjumps normal! F_
  let end_pos = getpos('.')

  keepjumps normal! f_
  let start_pos = getpos('.')
  return ['v', start_pos, end_pos]
endfunction

" ciao-come-stai

function! s:select_i() abort
  keepjumps normal! T_
  let end_pos = getpos('.')

  keepjumps normal! t_
  let start_pos = getpos('.')

  return ['v', start_pos, end_pos]
endfunction

let g:loaded_textobj_underscore = 1

