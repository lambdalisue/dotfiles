let g:mr#mru#predicates = [
      \ { v -> v !~# 'COMMIT_EDITMSG' }
      \]
let g:mr#mrw#predicates = [
      \ { v -> v !~# 'COMMIT_EDITMSG' }
      \]
