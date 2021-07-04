nmap g<C-n> <Plug>(altr-forward)
nmap g<C-p> <Plug>(altr-back)

function! s:my_altr() abort
  call altr#define('autoload/%.vim', 'doc/%.txt', 'plugin/%.vim')
  call altr#define('%.go', '%_test.go')
  call altr#define('kcdev/%.yml', 'kcstg/%.yml', 'kcprd/%.yml')
endfunction

augroup my_altr
  autocmd!
  autocmd VimEnter * call s:my_altr()
augroup END
