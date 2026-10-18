nnoremap <silent> <Leader>lu <Cmd>Lese mru<CR>
nnoremap <silent> <Leader>lr <Cmd>Lese mrr<CR>
nnoremap <silent> <Leader>lf <Cmd>Lese file<CR>
nnoremap <silent> <Leader>lb <Cmd>Lese buffer<CR>
nnoremap <silent> <Leader>lh <Cmd>Lese help<CR>
nnoremap <silent> <Leader>lg <Cmd>Lese rg<CR>
nnoremap <silent> <Leader>lq <Cmd>Lese quickfix<CR>
nnoremap <silent> <Leader>ld <Cmd>Lese config<CR>
nnoremap <silent> <Leader>lo <Cmd>Lese rg ~/Compost<CR>
nnoremap <silent> <Leader>ll <Cmd>Lese line<CR>
nnoremap <silent> <Leader>lS <Cmd>LeseSession<CR>
nnoremap <silent> <Leader>lR <Cmd>LeseResume<CR>
nnoremap <silent> * :<C-u>Lese -input="<C-r>=expand('<cword>')<CR>" line<CR>

function! s:init() abort
  cnoremap <silent><nowait> <C-p> <Plug>(lese-list-prev)
  cnoremap <silent><nowait> <C-n> <Plug>(lese-list-next)
  cnoremap <silent><nowait> <C-u> <Plug>(lese-list-prev:scroll)
  cnoremap <silent><nowait> <C-d> <Plug>(lese-list-next:scroll)
  cnoremap <silent><nowait> <C-t> <Plug>(lese-list-first)
  cnoremap <silent><nowait> <C-g> <Plug>(lese-list-last)
  cnoremap <silent><nowait> <PageUp> <Plug>(lese-list-left)
  cnoremap <silent><nowait> <PageDown> <Plug>(lese-list-right)
  cnoremap <silent><nowait> <S-PageUp> <Plug>(lese-list-left:scroll)
  cnoremap <silent><nowait> <S-PageDown> <Plug>(lese-list-right:scroll)

  cnoremap <silent><nowait> <Home> <Plug>(lese-preview-first)
  cnoremap <silent><nowait> <End> <Plug>(lese-preview-last)
  cnoremap <silent><nowait> <Up> <Plug>(lese-preview-prev)
  cnoremap <silent><nowait> <Down> <Plug>(lese-preview-next)
  cnoremap <silent><nowait> <S-Up> <Plug>(lese-preview-prev:scroll)
  cnoremap <silent><nowait> <S-Down> <Plug>(lese-preview-next:scroll)
  cnoremap <silent><nowait> <Left> <Plug>(lese-preview-left)
  cnoremap <silent><nowait> <Right> <Plug>(lese-preview-right)
  cnoremap <silent><nowait> <S-Left> <Plug>(lese-preview-left:scroll)
  cnoremap <silent><nowait> <S-Right> <Plug>(lese-preview-right:scroll)

  cnoremap <silent><nowait> <C-x> <Cmd>call lese#action('open:split')<CR>
  cnoremap <silent><nowait> <C-v> <Cmd>call lese#action('open:vsplit')<CR>
endfunction

augroup my_lese
  autocmd!
  autocmd User LesePreviewRendered:* setlocal nonumber norelativenumber
augroup END

