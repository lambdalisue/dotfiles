function! s:BufReadCmd() abort
  let name = matchstr(
      \ expand('<afile>'),
      \ 'bookmark://\zs.*'
      \)
  setlocal modifiable
  silent keepjumps %delete _
  silent execute printf("keepjumps 1read $MYVIM_HOME/bookmarks/%s", name)
  silent keepjumps 1delete _
  setlocal nomodifiable nomodified readonly
  setlocal buftype=nofile bufhidden=unload
  setlocal cursorline nolist nospell
  nnoremap <silent><buffer> <Return> gf
  nnoremap <silent><buffer> i :<C-u>call <SID>filter_bookmarks()<CR>
  call s:filter_bookmarks()
endfunction

function! s:show_bookmarks(name) abort
  execute "edit" printf("bookmark://%s", a:name)
endfunction

function! s:filter_bookmarks() abort
  let context = lista#context#new()
  let result = lista#start(context)
  if result.index isnot# -1
    call cursor(result.index + 1, col('.'), 0)
    normal! gf
  endif
endfunction

augroup bookmark_internal
  autocmd! *
  autocmd BufReadCmd bookmark://* nested call s:BufReadCmd()
augroup END

command! -nargs=1 Bookmark call s:show_bookmarks(<q-args>)
nnoremap <Space><Space>i :<C-u>Bookmark config<CR>
