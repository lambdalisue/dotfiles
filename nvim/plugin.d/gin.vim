nnoremap <silent> <Leader>aa <Cmd>GinStatus<CR>
nnoremap <silent> <Leader>ab <Cmd>GinBranch --all<CR>
nnoremap <silent> <Leader>al :<C-u>GinLog<CR>
nnoremap <silent> <Leader>aL :<C-u>GinLog -- %<CR>

function! s:show_commit(opener) abort
  let l:commit = matchstr(getline('.'), '\<[a-fA-F0-9]\{7,}\>')
  if empty(l:commit)
    return
  endif
  execute printf('GinBuffer ++opener=%s show %s', a:opener, l:commit)
endfunction

function! s:my_gitrebase() abort
  nnoremap <buffer> <Plug>(my-gin-show-commit:edit) <Cmd>call <SID>show_commit('edit')<CR>
  nnoremap <buffer> <Plug>(my-gin-show-commit:split) <Cmd>call <SID>show_commit('split')<CR>
  nnoremap <buffer> <Plug>(my-gin-show-commit:vsplit) <Cmd>call <SID>show_commit('vsplit')<CR>

  nnoremap <buffer> <CR> <Plug>(my-gin-show-commit:edit)
  nnoremap <buffer> g<CR> <Plug>(my-gin-show-commit:vsplit)
endfunction

function! s:my_gitcommit() abort
  nnoremap <buffer><nowait> <C-^> <Cmd>GinStatus<CR>
  nnoremap <buffer><nowait> <C-6> <Cmd>GinStatus<CR>
endfunction

function! s:my_gin_status() abort
  nnoremap <buffer><nowait> <C-^> <Cmd>Gin commit -v<CR>
  nnoremap <buffer><nowait> <C-6> <Cmd>Gin commit -v<CR>
  nmap <buffer><nowait> g<CR> <Plug>(gin-action-edit:HEAD)
endfunction

augroup my-gin
  autocmd!
  autocmd User GinComponentPost redrawtabline
  autocmd FileType gitrebase silent! call s:my_gitrebase()
  autocmd FileType gitcommit silent! call s:my_gitcommit()
  autocmd FileType gin-status silent! call s:my_gin_status()
augroup END

let g:gin_diff_default_args = [
      \ '++processor=delta --diff-highlight --keep-plus-minus-markers',
      \]
let g:gin_log_default_args = [
      \ '--pretty=%C(yellow)%h%C(reset)%C(auto)%d%C(reset) %s %C(cyan)@%an%C(reset) %C(magenta)[%ar]%C(reset)',
      \]
