call ddu#custom#patch_global({
      \ 'ui': 'ff',
      \ 'sources': [
      \   {
      \     'name': 'file_rec',
      \     'params': {
      \       'ignoredDirectories': ['.git', 'node_modules', 'venv'],
      \     },
      \   },
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
      \     'split': 'floating',
      \     'startFilter': v:true,
      \     'prompt': '> ',
      \   },
      \ },
      \})

function! s:my_ddu_ff() abort
  nnoremap <buffer><silent> <CR>
        \ <Cmd>call ddu#ui#ff#do_action('itemAction')<CR>
  nnoremap <buffer><silent> p
        \ <Cmd>call ddu#ui#ff#do_action('preview')<CR>
  nnoremap <buffer><silent> i
        \ <Cmd>call ddu#ui#ff#do_action('openFilterWindow')<CR>
  nnoremap <buffer><silent> <Esc>
        \ <Cmd>call ddu#ui#ff#do_action('quit')<CR>

  " Mark
  nnoremap <buffer><silent> -
        \ <Cmd>call ddu#ui#ff#do_action('toggleSelectItem')<CR>
  nnoremap <buffer><silent> <C-j>
        \ <Cmd>call ddu#ui#ff#do_action('toggleSelectItem')<CR>j
  nnoremap <buffer><silent> <C-k>
        \ k<Cmd>call ddu#ui#ff#do_action('toggleSelectItem')<CR>
endfunction

function! s:my_ddu_ff_filter() abort
  inoremap <buffer><silent> <CR> <Esc><Cmd>call ddu#ui#ff#do_action('itemAction')<CR>
  nnoremap <buffer><silent> <CR> <Cmd>call ddu#ui#ff#do_action('itemAction')<CR>
  inoremap <buffer><silent> <Esc> <Esc><Cmd>call ddu#ui#ff#close()<CR>
  nnoremap <buffer><silent> <Esc> <Cmd>call ddu#ui#ff#close()<CR>

  inoremap <buffer><silent> <C-n>
	  \ <Cmd>call ddu#ui#ff#execute("call cursor(line('.')+1,0)")<CR>
  inoremap <buffer><silent> <C-p>
	  \ <Cmd>call ddu#ui#ff#execute("call cursor(line('.')-1,0)")<CR>
endfunction

augroup my-ddu
  autocmd!
  autocmd FileType ddu-ff call s:my_ddu_ff()
  autocmd FileType ddu-ff-filter call s:my_ddu_ff_filter()
augroup END

function! s:ghq_root() abort
  return substitute(system("ghq root"), '\r\?\n$', '', '')
endfunction

nnoremap <silent> <Leader>dd <Cmd>call ddu#start({
      \ 'name': 'dotfiles',
      \ 'sources': [{
      \   'name': 'file_rec',
      \   'params': {
      \     'path': <SID>ghq_root() . '/github.com/lambdalisue/dotfiles',
      \     'ignoredDirectories': [
      \       '.git',
      \       '.addons',
      \       'pack',
      \     ],
      \   },
      \ }],
      \})<CR>
nnoremap <silent> <Leader>df <Cmd>call ddu#start({
      \ 'sources': [{
      \   'name': 'file_rec',
      \ }],
      \})<CR>
