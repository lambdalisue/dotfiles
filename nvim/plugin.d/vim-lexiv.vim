function! s:init_lexiv() abort
  " Use <C-y> instead in completion menu
  inoremap <expr> <CR> coc#pum#visible() ? "<C-y>" : lexiv#paren_expand()
endfunction

augroup my_lexiv
  autocmd!
  autocmd VimEnter * call s:init_lexiv()
augroup END
