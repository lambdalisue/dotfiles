function s:init() abort
  call ddu#custom#patch_global({
        \ 'ui': 'ff',
        \ 'sources': [
        \   {'name': 'mr', 'params': {}},
        \ ],
        \ 'sourceOptions': {
        \   '_': {
        \     'matchers': ['matcher_substring'],
        \   },
        \ },
        \ 'kindOptions': {
        \   'file': {
        \     'defaultAction': 'open',
        \   },
        \ },
        \ 'uiParams': {
        \   'ff': {
        \     'startFilter': v:true,
        \   },
        \ },
        \})
endfunction

function! s:ddu_init() abort
  nnoremap <buffer><silent><nowait> a
        \ <Cmd>call ddu#ui#ff#do_action('itemAction')<CR>
  nnoremap <buffer><silent><nowait> <CR>
        \ <Cmd>call ddu#ui#ff#do_action('itemAction')<CR>
  nnoremap <buffer><silent><nowait> m
        \ <Cmd>call ddu#ui#ff#do_action('toggleSelectItem')<CR>
  nnoremap <buffer><silent><nowait> i
        \ <Cmd>call ddu#ui#ff#do_action('openFilterWindow')<CR>
  nnoremap <buffer><silent><nowait> q
        \ <Cmd>call ddu#ui#ff#do_action('quit')<CR>
endfunction

function! s:ddu_filter_init() abort
  inoremap <buffer><silent> <CR>
        \ <Esc><Cmd>close<CR>
        \ <Cmd>call ddu#ui#ff#do_action('itemAction')<CR>
  nnoremap <buffer><silent> <CR>
        \ <Cmd>close<CR>
        \ <Cmd>call ddu#ui#ff#do_action('itemAction')<CR>
  inoremap <buffer><silent> <Esc>
        \ <Esc><Cmd>close<CR>
  nnoremap <buffer><silent> <Esc>
        \ <Cmd>close<CR>
endfunction

augroup my_ddu
  autocmd! *
  autocmd VimEnter * call s:init()
  autocmd FileType ddu-ff call s:ddu_init()
  autocmd FileType ddu-ff-filter call s:ddu_filter_init()
augroup END

nnoremap <silent> <Leader>dd <Cmd>call ddu#start({})<CR>
