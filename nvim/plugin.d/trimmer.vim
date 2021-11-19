augroup my-trimmer
  autocmd! *
  autocmd FileType yaml,perl,python,vim,vimspec,javascript,typescript,dosbatch,ps1,sh,iss,pascal call s:trimmer()
augroup END

function! s:trimmer() abort
  call timer_start(0, { -> execute('Trimmer! enable') })
endfunction
