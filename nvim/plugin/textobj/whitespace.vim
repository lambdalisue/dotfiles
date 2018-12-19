if exists('g:loaded_textobj_whitespace')
  finish
endif

silent! call textobj#user#plugin('whitespace', {
      \ '-': {
      \     '*sfile*': expand('<sfile>:p'),
      \     'select-a': 'a<Space>',  '*select-a-function*': 's:select_a',
      \     'select-i': 'i<Space>',  '*select-i-function*': 's:select_i'
      \   }
      \ })

function! s:select_a() abort
  execute 'keepjumps normal! F '
  let end_pos = getpos('.')

  execute 'keepjumps normal! f '
  let start_pos = getpos('.')
  return ['v', start_pos, end_pos]
endfunction

" ciao-come-stai

function! s:select_i() abort
  execute 'keepjumps normal! T '
  let end_pos = getpos('.')

  execute 'keepjumps normal! t '
  let start_pos = getpos('.')

  return ['v', start_pos, end_pos]
endfunction

let g:loaded_textobj_whitespace = 1
