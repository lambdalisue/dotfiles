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
  cnoremap <silent> <C-p> <Plug>(fall-list-prev)
  cnoremap <silent> <C-n> <Plug>(fall-list-next)
  cnoremap <silent> <Up> <Plug>(fall-list-prev)
  cnoremap <silent> <Down> <Plug>(fall-list-next)
  cnoremap <silent> <C-x> <Cmd>call fall#action('open:split')<CR>
  cnoremap <silent> <C-v> <Cmd>call fall#action('open:vsplit')<CR>
endfunction

augroup my_fall
  autocmd!
  autocmd User FallPickerEnter:* call s:init()
  autocmd User FallPreviewRendered:* setlocal nonumber norelativenumber
augroup END
