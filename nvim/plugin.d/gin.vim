nnoremap <silent> <Leader>aa <Cmd>GinStatus<CR>
nnoremap <silent> <Leader>ab <Cmd>GinBranch --all<CR>

function! s:my_gitcommit() abort
  nnoremap <buffer><nowait> <C-^> <Cmd>GinStatus<CR>

  if winnr('$') is# 1
    let winid = win_getid()
    botright vsplit | Gin! ++buffer diff --cached
    leftabove 10split | Gin! ++buffer diff --cached --stat
    call win_gotoid(winid)
    augroup my_gitcommit_internal
      autocmd! * <buffer>
      autocmd BufDelete <buffer> call timer_start(0, { -> execute('tabclose') })
    augroup END
  endif
endfunction

function! s:my_gin_status() abort
  nnoremap <buffer><nowait> <C-^> <Cmd>Gin commit -v<CR>
  nmap <buffer><nowait> g<CR> <Plug>(gin-action-edit:HEAD)
endfunction

augroup my-gin
  autocmd!
  autocmd FileType gitcommit silent! call s:my_gitcommit()
  autocmd FileType gin-status silent! call s:my_gin_status()
  autocmd BufEnter * ++nested redrawtabline
augroup END
