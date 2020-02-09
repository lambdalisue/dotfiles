function! s:smart_path() abort
  if !empty(&buftype) || bufname('%') =~# '^[^:]\+://'
    return fnamemodify('.', ':p')
  endif
  return fnamemodify(expand('%'), ':p:h')
endfunctio

nnoremap <silent> <Leader>ee :<C-u>Fern <C-r>=<SID>smart_path()<CR><CR>
nnoremap <silent> <Leader>EE :<C-u>Fern . -drawer -toggle -reveal=%<CR>

function! s:fern_init() abort
  " Call "tcd" as well on project drawer
  nmap <buffer><expr>
        \ <Plug>(fern-my-open-or-enter)
        \ fern#smart#drawer(
        \   "\<Plug>(fern-open-or-enter)\<Plug>(fern-action-tcd)",
        \   "\<Plug>(fern-open-or-enter)",
        \ )
  nmap <buffer><expr>
        \ <Plug>(fern-my-leave)
        \ fern#smart#drawer(
        \   "\<Plug>(fern-action-leave)\<Plug>(fern-action-tcd)",
        \   "\<Plug>(fern-action-leave)",
        \ )
  nmap <buffer><nowait> <Return> <Plug>(fern-my-open-or-enter)
  nmap <buffer><nowait> <Backspace> <Plug>(fern-my-leave)
  nmap <buffer><nowait> <C-m> <Plug>(fern-my-open-or-enter)
  nmap <buffer><nowait> <C-h> <Plug>(fern-my-leave)

  nmap <buffer><nowait> <Plug>(fern-action-open-and-stay) <Plug>(fern-action-open)<C-w><C-p>

  nmap <buffer><nowait> ~ :<C-u>Fern ~<CR>

  " Open bookmark:///
  " nnoremap <buffer><silent>
  "      \ <Plug>(fern-my-enter-bookmark)
  "      \ :<C-u>Fern bookmark:///<CR>
  " nmap <buffer><expr><silent>
  "      \ <C-^>
  "      \ fern#smart#scheme(
  "      \   "\<Plug>(fern-my-enter-bookmark)",
  "      \   {
  "      \     'bookmark': "\<C-^>",
  "      \   },
  "      \ )
endfunction

augroup my-fern
  autocmd! *
  autocmd FileType fern call s:fern_init()
augroup END

let g:fern#renderer = 'devicons'

augroup my-fern-hijack
  autocmd!
  autocmd BufEnter * nested call s:hijack_directory()
augroup END

function! s:hijack_directory() abort
  let path = expand('%')
  if !isdirectory(path)
    return
  endif
  bwipeout %
  execute 'Fern %'
endfunction
