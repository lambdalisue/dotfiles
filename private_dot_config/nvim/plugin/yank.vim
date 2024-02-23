function! s:yank_without_indent() abort
  normal! gvy
  let content = split(@@, '\n')
  let leading = min(map(copy(content), { _, v -> len(matchstr(v, '^\s*')) }))
  call map(content, { _, v -> v[leading:] })
  let @@ = join(content, "\n")
endfunction
vnoremap gy <Esc>:<C-u>call <SID>yank_without_indent()<CR>
