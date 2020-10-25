command! FzfMru call fzf#run({
      \ 'source': mr#mru#list(),
      \ 'sink': 'e',
      \ 'options': '-m -x +s',
      \ 'down': '40%',
      \})
