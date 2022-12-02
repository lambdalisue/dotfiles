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
      \   'action': {
      \     'defaultAction': 'do',
      \   },
      \   'file': {
      \     'defaultAction': 'open',
      \   },
      \ },
      \ 'uiParams': {
      \   'ff': {
      \     'prompt': '> ',
      \     'startFilter': v:true,
      \     'split': has('nvim') ? 'floating' : 'horizontal',
      \     'floatingBorder': 'single',
      \     'previewFloating': v:true,
      \     'previewFloatingBorder': 'single',
      \   },
      \ },
      \ 'filterParams': {
      \   'matcher_substring': {
      \     'highlightMatched': 'Search',
      \   },
      \ },
      \})

function! s:execute(expr) abort
  if !exists('g:ddu#ui#ff#_filter_parent_winid')
    return
  endif
  call win_execute(g:ddu#ui#ff#_filter_parent_winid, a:expr)
endfunction

function! s:my_ddu_ff() abort
  let b:coc_suggest_disable = 1

  nnoremap <nowait><buffer><silent> <CR>
        \ <Cmd>call ddu#ui#ff#do_action('itemAction')<CR>
  nnoremap <nowait><buffer><silent> a
        \ <Cmd>call ddu#ui#ff#do_action('chooseAction')<CR>
  nnoremap <nowait><buffer><silent> p
        \ <Cmd>call ddu#ui#ff#do_action('preview')<CR>
  nnoremap <nowait><buffer><silent> i
        \ <Cmd>call ddu#ui#ff#do_action('openFilterWindow')<CR>
  nnoremap <nowait><buffer><silent> <Esc>
        \ <Cmd>call ddu#ui#ff#do_action('quit')<CR>

  " Mark
  nnoremap <nowait><buffer><silent> -
        \ <Cmd>call ddu#ui#ff#do_action('toggleSelectItem')<CR>
  nnoremap <nowait><buffer><silent> <C-j>
        \ <Cmd>call ddu#ui#ff#do_action('toggleSelectItem')<CR>j
  nnoremap <nowait><buffer><silent> <C-k>
        \ k<Cmd>call ddu#ui#ff#do_action('toggleSelectItem')<CR>
endfunction

function! s:my_ddu_ff_filter() abort
  let b:coc_suggest_disable = 1

  inoremap <nowait><buffer><silent> <CR> <Esc><Cmd>call ddu#ui#ff#do_action('itemAction')<CR>
  nnoremap <nowait><buffer><silent> <CR> <Cmd>call ddu#ui#ff#do_action('itemAction')<CR>
  inoremap <nowait><buffer><silent> <Esc> <Esc><Cmd>call ddu#ui#ff#close()<CR>
  nnoremap <nowait><buffer><silent> <Esc> <Cmd>call ddu#ui#ff#close()<CR>

  inoremap <nowait><buffer><silent> <C-a> <Esc><Cmd>call ddu#ui#ff#do_action('chooseAction')<CR>
  inoremap <nowait><buffer><silent> <C-n> <Cmd>call <SID>execute('normal! j')<CR>
  inoremap <nowait><buffer><silent> <C-p> <Cmd>call <SID>execute('normal! k')<CR>
  inoremap <nowait><buffer><silent> <C-g> <Cmd>call <SID>execute('normal! j')<CR>
  inoremap <nowait><buffer><silent> <C-t> <Cmd>call <SID>execute('normal! k')<CR>
  inoremap <nowait><buffer><silent> <C-d> <Cmd>call <SID>execute("normal! \<C-d>")<CR>
  inoremap <nowait><buffer><silent> <C-u> <Cmd>call <SID>execute("normal! \<C-u>")<CR>
endfunction

augroup my-ddu
  autocmd!
  autocmd FileType ddu-ff call s:my_ddu_ff()
  autocmd FileType ddu-ff-filter call s:my_ddu_ff_filter()
augroup END

function! s:ghq_root() abort
  return substitute(system("ghq root"), '\r\?\n$', '', '')
endfunction

nnoremap <silent> <Leader>mm <Cmd>call ddu#start({
      \ 'name': 'mrw',
      \ 'sources': [{
      \   'name': 'mr',
      \   'params': {
      \     'kind': 'mrw',
      \   },
      \ }],
      \})<CR>
nnoremap <silent> <Leader>dd <Cmd>call ddu#start({
      \ 'name': 'dotfiles',
      \ 'sources': [{
      \   'name': 'file_rec',
      \   'params': {
      \     'ignoredDirectories': [
      \       '.git',
      \       '.addons',
      \       'pack',
      \     ],
      \   },
      \   'options': {
      \     'path': <SID>ghq_root() . '/github.com/lambdalisue/dotfiles',
      \   },
      \ }],
      \})<CR>
nnoremap <silent> <Leader>jj <Cmd>call ddu#start({
      \ 'name': 'junkfiles',
      \ 'sources': [{
      \   'name': 'file_rec',
      \   'options': {
      \     'path': expand(g:junkfile#directory),
      \   },
      \ }],
      \})<CR>
nnoremap <silent> <Leader>df <Cmd>call ddu#start({
      \ 'sources': [{
      \   'name': 'file_rec',
      \ }],
      \})<CR>
