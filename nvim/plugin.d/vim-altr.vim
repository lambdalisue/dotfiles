if &runtimepath !~# 'vim-altr'
  finish
endif

nmap g<C-n> <Plug>(altr-forward)
nmap g<C-p> <Plug>(altr-back)

function! s:init_altr() abort
  call altr#define(
        \ 'src/components/%/view.vue',
        \ 'storybook/stories/core/components/%.stories.ts',
        \)
  call altr#define(
        \ 'src/modules/%/components/%/view.vue',
        \ 'storybook/stories/%/components/%.stories.ts',
        \)
endfunction

call s:init_altr()
