function! s:smart_path() abort
  if !empty(&buftype) || bufname('%') =~# '^[^:]\+://'
    return fnamemodify('.', ':p')
  endif
  return fnamemodify(expand('%'), ':p:h')
endfunction

nnoremap <silent> <Leader>ee :<C-u>Fern <C-r>=<SID>smart_path()<CR> -reveal=%<CR>
nnoremap <silent> <Leader>EE :<C-u>Fern . -drawer -toggle -reveal=%<CR>
nnoremap <silent> <Leader>ii :<C-u>Fern bookmark:/// -wait<BAR>FinCR<CR>
nnoremap <silent> <Leader>JJ :<C-u>Fern <C-r>=expand(g:junkfile#directory)<CR> -wait<CR>:<C-u>execute "normal fa"<CR>
nnoremap <silent> <Leader>KK :<C-u>Fern . -wait<CR>:<C-u>execute "normal fa"<CR>

function! s:fern_init() abort
  if has('mac') && !exists('$SSH_CONNECTION')
    let g:fern#renderer = 'nerdfont'
  endif
  let g:fern#keepalt_on_edit = 1
  let g:fern#smart_cursor = has('nvim-0.5.0') ? 'hide' : 'stick'
  let g:fern#loglevel = g:fern#DEBUG
endfunction

function! s:fern_local_init() abort
  nmap <buffer>
        \ <Plug>(fern-my-enter-and-tcd)
        \ <Plug>(fern-action-enter)<Plug>(fern-wait)<Plug>(fern-action-tcd:root)
  nmap <buffer>
        \ <Plug>(fern-my-leave-and-tcd)
        \ <Plug>(fern-action-leave)<Plug>(fern-wait)<Plug>(fern-action-tcd:root)
  nmap <buffer><expr>
        \ <Plug>(fern-my-open-or-enter-and-tcd)
        \ fern#smart#leaf(
        \   "\<Plug>(fern-action-open)",
        \   "\<Plug>(fern-my-enter-and-tcd)",
        \ )
  nmap <buffer><expr>
        \ <Plug>(fern-my-open-or-enter)
        \ fern#smart#drawer(
        \   "\<Plug>(fern-my-open-or-enter-and-tcd)",
        \   "\<Plug>(fern-action-open-or-enter)",
        \ )
  nmap <buffer><expr>
        \ <Plug>(fern-my-leave)
        \ fern#smart#drawer(
        \   "\<Plug>(fern-my-leave-and-tcd)",
        \   "\<Plug>(fern-action-leave)",
        \ )
  nmap <buffer><nowait> <C-m> <Return>
  nmap <buffer><nowait> <C-h> <Backspace>
  nmap <buffer><nowait> <Return>    <Plug>(fern-my-open-or-enter)
  nmap <buffer><nowait> <Backspace> <Plug>(fern-my-leave)
  nnoremap <buffer><nowait> # :<C-u>FinCR<CR>
  nnoremap <buffer><nowait> ~ :<C-u>Fern ~<CR>
endfunction

augroup my-fern
  autocmd! *
  autocmd FileType fern call s:fern_local_init()
  autocmd VimEnter * silent! call s:fern_init()
augroup END
