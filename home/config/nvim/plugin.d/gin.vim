nnoremap <silent> <Leader>aa :<C-u>GinStatus<CR><CR>
nnoremap <silent> <Leader>ab <Cmd>GinBranch --all<CR>
nnoremap <silent> <Leader>al :<C-u>GinLog<CR>
nnoremap <silent> <Leader>aL :<C-u>GinLog origin/main... -- %:p<CR>

function! s:show_commit(opener) abort
  let l:commit = matchstr(getline('.'), '\<[a-fA-F0-9]\{7,}\>')
  if empty(l:commit)
    return
  endif
  execute printf('GinBuffer ++opener=%s ++difffold ++diffjump=%s show %s', a:opener, l:commit, l:commit)
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
  nnoremap <buffer><nowait> g<C-^> <Cmd>Gin commit -v --amend<CR>
  nnoremap <buffer><nowait> g<C-6> <Cmd>Gin commit -v --amend<CR>
  nmap <buffer><nowait> g<CR> <Plug>(gin-action-edit:HEAD)
  setl cursorline
endfunction

function! s:my_gin_log() abort
  nnoremap <buffer> <Plug>(gin-action-show) <Plug>(gin-action-show:emojify)
  nnoremap <buffer> <Plug>(gin-action-stat) 
        \ <Plug>(gin-action-yank:commit)
        \ :GinBuffer diff --stat <C-r>+~..<C-r>+<CR>
  nnoremap <buffer> <Plug>(gin-action-fixup:instant) <Plug>(gin-action-fixup:instant-fixup)
  setl cursorline
endfunction

function! s:define_gin_local() abort
  command! -buffer -bar GinLocal execute printf('edit +%d', line('.')) gin#util#expand('%:p')
endfunction

augroup my-gin
  autocmd!
  autocmd User GinComponentPost redrawtabline
  autocmd FileType gitrebase silent! call s:my_gitrebase()
  autocmd FileType gitcommit silent! call s:my_gitcommit()
  autocmd FileType gin-status silent! call s:my_gin_status()
  autocmd FileType gin-log silent! call s:my_gin_log()
  autocmd BufReadCmd ginedit://* call s:define_gin_local()
  autocmd BufReadCmd gindiff://* call s:define_gin_local()
  autocmd BufReadCmd ginlog://* call s:define_gin_local()
augroup END

if executable('delta')
  let g:gin_diff_persistent_args = [
        \ '++processor=delta --diff-highlight --keep-plus-minus-markers',
        \]
endif

let g:gin_log_persistent_args = [
      \ '++emojify',
      \ '--pretty=%C(yellow)%h%C(reset)%C(auto)%d%C(reset) %s %C(cyan)@%an%C(reset) %C(magenta)[%ar]%C(reset)',
      \]

let g:gin_proxy_apply_without_confirm = 1

let g:gin_difffold_prefixes = g:gin#difffold#prefixes_nerdfont
