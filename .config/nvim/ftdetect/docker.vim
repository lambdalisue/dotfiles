function! s:filetype_dockerfile() abort
  if expand('%:p:g?\\?/?') =~# 'dockerfiles/[^/]\+$' && getline(1) =~# '\%(^FROM \|docker\)'
    set filetype=Dockerfile
  endif
endfunction
autocmd BufNewFile,BufRead Dockerfile.* set filetype=Dockerfile
autocmd BufWinEnter *
      \ if &filetype ==# 'conf' || &filetype ==# '' |
      \   call s:filetype_dockerfile() |
      \ endif
