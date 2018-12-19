function! s:to_view() abort
  setl buftype=help
  setl nomodifiable readonly
  setl nolist
  setl nospell
  setl colorcolumn=
  setl conceallevel=2
  setl concealcursor=nv
endfunction

function! s:to_edit() abort
  setl buftype=
  setl modifiable noreadonly
  setl tabstop=8 shiftwidth=8 softtabstop=8
  setl nosmarttab noexpandtab textwidth=78
  setl list
  setl spell
  setl colorcolumn=+1
  setl conceallevel=1
  setl concealcursor=
endfunction

function! s:toggle() abort
  if &l:buftype ==# 'help'
    call s:to_edit()
  else
    call s:to_view()
  endif
endfunction

command! -buffer -bar HelpEdit call s:to_edit()
command! -buffer -bar HelpView call s:to_view()
command! -buffer -bar HelpToggle call s:toggle()

nnoremap <buffer><silent> <C-s> :<C-u>HelpToggle<CR>

if &l:buftype ==# 'help'
  call s:to_view()
  finish
else
  call s:to_edit()
endif

function! s:get_text_on_cursor(pat) abort
  let line = getline('.')
  let pos = col('.')
  let s = 0
  while s < pos
    let [s, e] = [match(line, a:pat, s), matchend(line, a:pat, s)]
    if s < 0
      break
    elseif s < pos && pos <= e
      return line[s : e - 1]
    endif
    let s += 1
  endwhile
  return ''
endfunction

function! s:jump_to_tag() abort
  let tag = s:get_text_on_cursor('|\zs[^|]\+\ze|')
  if tag !=# ''
    let pat = escape(tag, '\')
    if !search('\V*\zs' . pat . '*', 'w')
      execute 'help' tag
    endif
  endif
endfunction
nnoremap <buffer> <silent> <C-]> :<C-u>call <SID>jump_to_tag()<CR>
