let g:bakaup_auto_backup = 1
let g:bakaup_backup_dir = expand("~/.cache/bakaup")

function! s:init_bakaup() abort
  command! BakaupExplore execute printf("Fern %s", fnameescape(g:bakaup_backup_dir))
  silent! delcommand BakaupTexplore
  silent! delcommand BakaupVexplore
  silent! delcommand BakaupSexplore
endfunction

augroup bakaup
  autocmd!
  autocmd VimEnter * call s:init_bakaup()
augroup END
