setlocal nofoldenable
setlocal foldcolumn=0
setlocal nonumber
setlocal norelativenumber
setlocal signcolumn=no

augroup my-terminal
  autocmd! * <buffer>
  autocmd WinLeave <buffer> stopinsert
augroup END

startinsert
