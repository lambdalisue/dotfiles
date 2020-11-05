function! s:start_project(path) abort
  tabnew
  execute printf('tcd %s', fnameescape(a:path))
  Fern .
endfunction

command! FzfMrr call fzf#run({
      \ 'source': mr#mrr#list(),
      \ 'sink': funcref('s:start_project'),
      \ 'options': '-m -x +s',
      \ 'down': '40%',
      \})

command! FzfMru call fzf#run({
      \ 'source': mr#mru#list(),
      \ 'sink': 'e',
      \ 'options': '-m -x +s',
      \ 'down': '40%',
      \})

nnoremap <Leader>mu :<C-u>FzfMru<CR>
nnoremap <Leader>mr :<C-u>FzfMrr<CR>
