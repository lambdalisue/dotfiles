if !exists('$SSH_CONNECTION')
  let g:fern#renderer = 'nerdfont'
endif


let g:fern#hide_cursor = 1
let g:fern#keepalt_on_edit = 1
let g:fern#default_hidden = 1
let g:fern#default_exclude = '\%(\.DS_Store\|__pycache__\)'
let g:fern#renderer#nerdfont#indent_markers = 1

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
  nmap <buffer><nowait> T <Plug>(fern-action-terminal)
  nnoremap <buffer><nowait> ~ :<C-u>Fern ~<CR>

  nmap <buffer> K <Nop>
  nmap <buffer> N <Plug>(fern-action-new-path)

  nmap <buffer> <Plug>(fern-action-dirdiff) <Plug>(fern-action-ex=)DirDiff<CR>
endfunction

augroup my-fern
  autocmd! *
  autocmd FileType fern call s:fern_local_init()
augroup END

function! s:ghq_root() abort
  return substitute(system("ghq root"), '\r\?\n$', '', '')
endfunction

function! s:smart_path() abort
  if !empty(&buftype) || bufname('%') =~# '^[^:]\+://'
    return escape(fnameescape(fnamemodify('.', ':p')), '\')
  endif
  return escape(fnameescape(fnamemodify(expand('%'), ':p:h')), '\')
endfunction

nnoremap <silent> <Leader>ee :<C-u>Fern <C-r>=<SID>smart_path()<CR> -reveal=%:p<CR>
nnoremap <silent> <Leader>EE :<C-u>Fern . -drawer -reveal=%<CR>
nnoremap <silent> <Leader>gg :<C-u>Fern <C-r>=<SID>ghq_root()<CR>/github.com -reveal=lambdalisue<CR>
nnoremap <silent> <Leader>DD :<C-u>Fern <C-r>=<SID>ghq_root()<CR>/github.com/lambdalisue/dotfiles -reveal=%:p<CR>
nnoremap <silent> <Leader>JJ :<C-u>Fern <C-r>=expand(g:junkfile#directory)<CR> -reveal=%:p<CR>
