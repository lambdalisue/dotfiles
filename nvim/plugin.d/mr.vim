command! FzfMru call fzf#run({
      \ 'source': mr#mru#list(),
      \ 'sink': 'e',
      \ 'options': '-m -x +s',
      \ 'down': '40%',
      \})

nnoremap <Leader>mm :<C-u>Mru . <BAR> FinQf<CR>
nnoremap <Leader>mu :<C-u>Mru . <BAR> FinQf<CR>
nnoremap <Leader>mw :<C-u>Mrw . <BAR> FinQf<CR>
