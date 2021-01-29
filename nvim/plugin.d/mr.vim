function! s:start_project(path) abort
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

command! FzfMruLocal call fzf#run({
      \ 'source': mr#filter(mr#mru#list(), getcwd()),
      \ 'sink': 'e',
      \ 'options': '-m -x +s',
      \ 'down': '40%',
      \})

nnoremap <Leader>mm :<C-u>FzfMruLocal<CR>
nnoremap <Leader>mM :<C-u>FzfMru<CR>
nnoremap <Leader>II :<C-u>FzfMrr<CR>
