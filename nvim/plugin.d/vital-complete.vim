augroup my-vimtal-complete
  autocmd! *
  autocmd FileType vim,vimspec setlocal completefunc=vital_complete#complete
augroup END
