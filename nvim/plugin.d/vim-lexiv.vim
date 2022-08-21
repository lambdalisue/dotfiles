function! s:init_lexiv() abort
  " Use <C-y> instead in completion menu
  inoremap <expr> <CR> SafePumVisible() ? "<C-y>" : lexiv#paren_expand()
endfunction

augroup my_lexiv
  autocmd!
  autocmd VimEnter * call s:init_lexiv()
augroup END
