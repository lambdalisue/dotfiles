function! s:fila_viewer_init() abort
  nmap <buffer><expr> <Plug>(fila-custom-smart-enter) fila#viewer#drawer#is_drawer(win_getid())
        \ ? "\<Plug>(fila-action-enter-or-edit)\<Plug>(fila-action-tcd)"
        \ : "\<Plug>(fila-action-enter-or-edit)"
  nmap <buffer><expr> <Plug>(fila-custom-smart-leave) fila#viewer#drawer#is_drawer(win_getid())
        \ ? "\<Plug>(fila-action-leave)\<Plug>(fila-action-tcd)"
        \ : "\<Plug>(fila-action-leave)"

  nmap <buffer><nowait> <Enter> <Plug>(fila-custom-smart-enter)
  nmap <buffer><nowait> <C-m> <Plug>(fila-custom-smart-enter)
  nmap <buffer><nowait> <Backspace> <Plug>(fila-custom-smart-leave)
  nmap <buffer><nowait> <C-h> <Plug>(fila-custom-smart-leave)

  nmap <buffer><nowait> w <Plug>(fila-action-expand-or-collapse)
  nmap <buffer><nowait> s <Plug>(fila-action-edit-select)
  nmap <buffer><nowait> p <Plug>(fila-action-edit-pedit)
  nmap <buffer><nowait> <C-j> <Plug>(fila-action-mark-toggle)j
  nmap <buffer><nowait> <C-k> <Plug>(fila-action-mark-toggle)k
  nmap <buffer><nowait> N  <Plug>(fila-action-new-file)
  nmap <buffer><nowait> K  <Plug>(fila-action-new-directory)
  nmap <buffer><nowait> m  <Plug>(fila-action-move)
  nmap <buffer><nowait> c  <Plug>(fila-action-copy)
  nmap <buffer><nowait> p  <Plug>(fila-action-paste)
  nmap <buffer><nowait> d  <Plug>(fila-action-delete)
endfunction

autocmd MyAutoCmd User FilaViewerInit call s:fila_viewer_init()

nnoremap <silent> <Leader>EE :<C-u>Fila . -drawer -reveal=<C-r>=expand('%')<CR><CR>
nnoremap <silent> <Leader>ee :<C-u>Fila<CR>
