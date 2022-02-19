nnoremap <silent> <Leader>aa :<C-u>GinStatus ++worktree=<C-r>=<SID>smart_worktree()<CR><CR>

function! s:smart_worktree() abort
  let dir = expand("%:p:h")
  if isdirectory(dir)
    return dir
  endif
  return getcwd()
endfunction

function! s:my_gitcommit() abort
  nmap <buffer><nowait> <C-^> <Cmd>GinStatus<CR>
endfunction

function! s:my_gin_status() abort
  nmap <buffer><nowait> <C-^> <Cmd>Gin commit -v<CR>
  map <buffer><nowait> !! <Plug>(gin-action-chaperon)
  map <buffer><nowait> pp <Plug>(gin-action-patch)
  map <buffer><nowait> dd <Plug>(gin-action-diff:smart)
  map <buffer><nowait> == <Plug>(gin-action-stash)
  map <buffer><nowait> << <Plug>(gin-action-stage)
  map <buffer><nowait> >> <Plug>(gin-action-unstage)
  map <buffer><nowait> <Return> <Plug>(gin-action-edit)
endfunction

augroup my-gin
  autocmd!
  autocmd FileType gitcommit silent! call s:my_gitcommit()
  autocmd FileType gin-status silent! call s:my_gin_status()
augroup END
