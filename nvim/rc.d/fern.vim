nnoremap <silent> <Leader>ee :<C-u>Fern <C-r>=<SID>smart_path()<CR><CR>
nnoremap <silent> <Leader>EE :<C-u>Fern . -drawer -toggle -reveal=%<CR>

function! s:fern_init() abort
  let scheme = s:find_scheme()

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

  " Find and enter project root
  if scheme ==# 'file'
    nnoremap <buffer><silent>
          \ <Plug>(fern-action-enter-project-root)
          \ :<C-u>call fern#helper#call(funcref("<SID>map_enter_project_root"))<CR>
    nmap <buffer><nowait> ^ <Plug>(fern-action-enter-project-root)
  endif

  if scheme ==# 'bookmark'
    echomsg "This is bookmark tree"
  else
    nnoremap <buffer><silent> <C-^> :<C-u>Fern bookmark:///<CR>
  endif
endfunction

" XXX: Provide similar function officially in fern.vim ?
function! s:find_scheme() abort
  return fern#fri#parse(fern#fri#parse(bufname('%')).path).scheme
endfunction

function! s:smart_path() abort
  if !empty(&buftype) || bufname('%') =~# '^[^:]\+://'
    return fnamemodify('.', ':p')
  endif
  return fnamemodify(expand('%'), ':p:h')
endfunctio

function! s:map_enter_project_root(helper) abort
  " NOTE: require 'file' scheme
  let root = a:helper.get_root_node()
  let path = root._path
  let path = finddir('.git/..', path . ';')
  execute printf('Fern %s', fnameescape(path))
endfunction

autocmd MyAutoCmd FileType fern call s:fern_init()
