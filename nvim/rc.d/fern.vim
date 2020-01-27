nnoremap <silent> <Leader>oo :<C-u>Fern bookmark:<CR>
nnoremap <silent> <Leader>ee :<C-u>Fern <C-r>=<SID>smart_path()<CR><CR>
nnoremap <silent> <Leader>EE :<C-u>Fern . -drawer -reveal=%<CR>

function! s:fern_init() abort
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

  " nmap <buffer><expr>
  "      \ <Plug>(fern-my-expand-or-enter)
  "      \ fern#smart#drawer(
  "      \   "\<Plug>(fern-open-or-expand)",
  "      \   "\<Plug>(fern-open-or-enter)",
  "      \ )
  " nmap <buffer><expr>
  "      \ <Plug>(fern-my-collapse-or-leave)
  "      \ fern#smart#drawer(
  "      \   "\<Plug>(fern-action-collapse)",
  "      \   "\<Plug>(fern-action-leave)",
  "      \ )
  " nmap <buffer><nowait> l <Plug>(fern-my-expand-or-enter)
  " nmap <buffer><nowait> h <Plug>(fern-my-collapse-or-leave)
endfunction

function! s:smart_path() abort
  if !empty(&buftype) || bufname('%') =~# '^[^:]\+://'
    return fnamemodify('.', ':p')
  endif
  return fnamemodify(expand('%'), ':p:h')
endfunctio

autocmd MyAutoCmd FileType fern call s:fern_init()
