augroup my-vimtal-complete
  autocmd! *
  autocmd FileType vim,vimspec setlocal omnifunc=vital_complete#complete
augroup END

