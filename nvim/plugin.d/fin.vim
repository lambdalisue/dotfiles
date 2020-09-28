nnoremap # :<C-u>Fin<CR>

command! FinMru botright copen | Mru | FinCR | cclose
command! FinMrw botright copen | Mrw | FinCR | cclose

nnoremap <Leader>mm :<C-u>FinMru<CR>
nnoremap <Leader>mu :<C-u>FinMru<CR>
nnoremap <Leader>mw :<C-u>FinMrw<CR>
