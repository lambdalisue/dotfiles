nnoremap <silent> <Leader>aa <Cmd>GinStatus<CR>
nnoremap <silent> <Leader>ab <Cmd>GinBranch --all<CR>

function! s:my_gitcommit() abort
  nnoremap <buffer><nowait> <C-^> <Cmd>GinStatus<CR>
endfunction

function! s:my_gin_status() abort
  nnoremap <buffer><nowait> <C-^> <Cmd>Gin commit -v<CR>
  nmap <buffer><nowait> g<CR> <Plug>(gin-action-edit:HEAD)
endfunction

augroup my-gin
  autocmd!
  autocmd FileType gitcommit silent! call s:my_gitcommit()
  autocmd FileType gin-status silent! call s:my_gin_status()
augroup END

let g:loaded_gin_status_supplement = 1
let g:loaded_gin_branch_supplement = 1
let g:loaded_gin_gitcommit_supplement = 1
let g:loaded_gin_gitrebase_supplement = 1

let g:gin_diff_default_args = [
      \ '++processor=delta --diff-highlight --keep-plus-minus-markers',
      \]
