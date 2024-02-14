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
      \     'matchers': ['merge'],
      \   },
      \ },
      \ 'kindOptions': {
      \   'action': {
      \     'defaultAction': 'do',
      \   },
      \   'file': {
      \     'defaultAction': 'open',
      \   },
      \   'help': {
      \     'defaultAction': 'open',
      \   },
      \   'ui_select': {
      \     'defaultAction': 'select',
      \   },
      \ },
      \ 'uiParams': {
      \   'ff': {
      \     'prompt': '> ',
      \     'split': has('nvim') ? 'floating' : 'horizontal',
      \     'floatingBorder': 'single',
      \     'previewFloating': v:true,
      \     'previewFloatingBorder': 'single',
      \     'highlights': {
      \       'floating': 'Normal',
      \     },
      \   },
      \ },
      \ 'filterParams': {
      \   'merge': #{
      \     filters: [
      \       #{name: 'matcher_kensaku', weight: 2.0},
      \       'matcher_matchfuzzy'
      \     ],
      \   },
      \   'matcher_matchfuzzy': {
      \     'highlightMatched': 'Search',
      \   },
      \   'matcher_substring': {
      \     'highlightMatched': 'Search',
      \   },
      \   'matcher_kensaku': {
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

  setlocal cursorline

  nnoremap <nowait><buffer><silent> <CR>
        \ <Cmd>call ddu#ui#do_action('itemAction')<CR>
  nnoremap <nowait><buffer><silent> a
        \ <Cmd>call ddu#ui#do_action('chooseAction')<CR>
  nnoremap <nowait><buffer><silent> p
        \ <Cmd>call ddu#ui#do_action('preview')<CR>
  nnoremap <nowait><buffer><silent> i
        \ <Cmd>call ddu#ui#do_action('openFilterWindow')<CR>
  nnoremap <nowait><buffer><silent> <Esc>
        \ <Cmd>call ddu#ui#do_action('quit')<CR>

  " Mark
  nnoremap <nowait><buffer><silent> -
        \ <Cmd>call ddu#ui#do_action('toggleSelectItem')<CR>
  nnoremap <nowait><buffer><silent> <C-j>
        \ <Cmd>call ddu#ui#do_action('toggleSelectItem')<CR>j
  nnoremap <nowait><buffer><silent> <C-k>
        \ k<Cmd>call ddu#ui#ff#do_action('toggleSelectItem')<CR>
endfunction

function! s:my_ddu_ff_filter() abort
  let b:coc_suggest_disable = 1

  inoremap <nowait><buffer><silent> <CR> <Esc><Cmd>call ddu#ui#do_action('itemAction')<CR>
  nnoremap <nowait><buffer><silent> <CR> <Cmd>call ddu#ui#do_action('itemAction')<CR>
  inoremap <nowait><buffer><silent> <Esc> <Esc><Cmd>call ddu#ui#do_action('closeFilterWindow')<CR>
  nnoremap <nowait><buffer><silent> <Esc> <Cmd>call ddu#ui#do_action('closeFilterWindow')<CR>

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
      \ 'uiOptions': {
      \   'ff': {
      \     'defaultAction': 'cd',
      \   },
      \ },
      \})<CR>
nnoremap <silent> <Leader>mr <Cmd>call ddu#start({
      \ 'name': 'mrr',
      \ 'sources': [{
      \   'name': 'mr',
      \   'params': {
      \     'kind': 'mrr',
      \   },
      \ }],
      \ 'uiOptions': {
      \   'ff': {
      \     'defaultAction': 'cd',
      \   },
      \ },
      \})<CR>
nnoremap <silent> <Leader>ll <Cmd>call ddu#start({
      \ 'name': 'line',
      \ 'sources': [{
      \   'name': 'line',
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
      \ 'sourceOptions': {
      \   '_': {
      \     'sorters': ['sorter_alpha', 'sorter_reversed'],
      \   },
      \ },
      \})<CR>
nnoremap <silent> <Leader>df <Cmd>call ddu#start({
      \ 'sources': [{
      \   'name': 'file_rec',
      \ }],
      \})<CR>
nnoremap <silent> <Leader>dc <Cmd>call ddu#start({
      \ 'sources': [{
      \   'name': 'docbase_memo',
      \ }],
      \})<CR>
nnoremap <silent> <Leader>dh <Cmd>call ddu#start({
      \ 'sources': [{
      \   'name': 'help',
      \ }],
      \})<CR>
