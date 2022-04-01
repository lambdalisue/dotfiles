function s:init() abort
  call ddu#custom#patch_global({
        \ 'ui': 'ff',
        \ 'uiParams': {
        \   'ff': {
        \     'split': 'floating',
        \   },
        \ },
        \ 'sources': [{'name': 'file_rec', 'params': {}}],
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
        \})
endfunction

function! s:ddu_init() abort
  nnoremap <buffer><silent><nowait> <CR>
        \ <Cmd>call ddu#ui#ff#do_action('itemAction')<CR>
  nnoremap <buffer><silent><nowait> m
        \ <Cmd>call ddu#ui#ff#do_action('toggleSelectItem')<CR>
  nnoremap <buffer><silent><nowait> i
        \ <Cmd>call ddu#ui#ff#do_action('openFilterWindow')<CR>
  nnoremap <buffer><silent><nowait> p
        \ <Cmd>call ddu#ui#ff#do_action('preview')<CR>
  nnoremap <buffer><silent><nowait> <Esc>
        \ <Cmd>call ddu#ui#ff#do_action('quit')<CR>
endfunction

function! s:ddu_filter_init() abort
  inoremap <buffer><silent> <CR>
        \ <Cmd>call ddu#ui#ff#do_action('itemAction')<CR>
  inoremap <buffer><silent> <Esc>
        \ <Cmd>close<CR>
  inoremap <buffer><silent> <C-g>
        \ <Cmd>call ddu#ui#ff#execute('call cursor(line(".")+1, 0)')<CR>
  inoremap <buffer><silent> <C-t>
        \ <Cmd>call ddu#ui#ff#execute('call cursor(line(".")-1, 0)')<CR>
endfunction

augroup my_ddu
  autocmd! *
  autocmd VimEnter * call s:init()
  autocmd FileType ddu-ff call s:ddu_init()
  autocmd FileType ddu-ff-filter call s:ddu_filter_init()
augroup END

nnoremap <silent> <Leader>dd <Cmd>call ddu#start({})<CR>
