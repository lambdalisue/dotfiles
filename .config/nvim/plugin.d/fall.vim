nnoremap <silent> <Leader>ff <Cmd>Fall file<CR>
nnoremap <silent> <Leader>fb <Cmd>Fall buffer<CR>
nnoremap <silent> <Leader>fh <Cmd>Fall help<CR>
nnoremap <silent> <Leader>fg <Cmd>Fall rg<CR>
nnoremap <silent> <Leader>fq <Cmd>Fall quickfix<CR>
nnoremap <silent> <Leader>fd <Cmd>Fall file ~/ogh/lambdalisue/dotfiles<CR>
nnoremap <silent> <Leader>fo <Cmd>Fall file ~/ObsidianVault<CR>
nnoremap <silent> <Leader>fj <Cmd>Fall file ~/Documents/vim/junkfiles<CR>
nnoremap <silent> <Leader>fl <Cmd>Fall line<CR>
nnoremap <silent> <Leader>mm <Cmd>Fall mru<CR>
nnoremap <silent> <Leader>mw <Cmd>Fall mrw<CR>
nnoremap <silent> <Leader>mr <Cmd>Fall mrr<CR>
nnoremap <silent> <Leader>md <Cmd>Fall mrd<CR>
nnoremap <silent> <C-x><C-g> <Cmd>Fall file ~/ogh<CR>

function! s:init() abort
  cnoremap <silent><nowait> <C-p> <Plug>(fall-list-prev)
  cnoremap <silent><nowait> <C-n> <Plug>(fall-list-next)
  cnoremap <silent><nowait> <C-u> <Plug>(fall-list-prev:scroll)
  cnoremap <silent><nowait> <C-d> <Plug>(fall-list-next:scroll)
  cnoremap <silent><nowait> <C-t> <Plug>(fall-list-first)
  cnoremap <silent><nowait> <C-g> <Plug>(fall-list-last)
  cnoremap <silent><nowait> <PageUp> <Plug>(fall-list-left)
  cnoremap <silent><nowait> <PageDown> <Plug>(fall-list-right)
  cnoremap <silent><nowait> <S-PageUp> <Plug>(fall-list-left:scroll)
  cnoremap <silent><nowait> <S-PageDown> <Plug>(fall-list-right:scroll)

  cnoremap <silent><nowait> <Home> <Plug>(fall-preview-first)
  cnoremap <silent><nowait> <End> <Plug>(fall-preview-last)
  cnoremap <silent><nowait> <Up> <Plug>(fall-preview-prev)
  cnoremap <silent><nowait> <Down> <Plug>(fall-preview-next)
  cnoremap <silent><nowait> <S-Up> <Plug>(fall-preview-prev:scroll)
  cnoremap <silent><nowait> <S-Down> <Plug>(fall-preview-next:scroll)
  cnoremap <silent><nowait> <Left> <Plug>(fall-preview-left)
  cnoremap <silent><nowait> <Right> <Plug>(fall-preview-right)
  cnoremap <silent><nowait> <S-Left> <Plug>(fall-preview-left:scroll)
  cnoremap <silent><nowait> <S-Right> <Plug>(fall-preview-right:scroll)

  cnoremap <silent><nowait> <C-x> <Cmd>call fall#action('open:split')<CR>
  cnoremap <silent><nowait> <C-v> <Cmd>call fall#action('open:vsplit')<CR>
endfunction

augroup my_fall
  autocmd!
  autocmd User FallPickerEnter:* call s:init()
  autocmd User FallPreviewRendered:* setlocal nonumber norelativenumber
augroup END
