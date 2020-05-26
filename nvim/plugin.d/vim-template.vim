function! s:template_keywords() abort
  silent! %s/<+FILE NAME+>/\=expand('%:t')/g
  silent! %s/<+DATE+>/\=strftime('%Y-%m-%d')/g
  silent! %s/<%=\(.\{-}\)%>/\=eval(submatch(1))/ge
  if search('<+CURSOR+>')
    execute 'normal! "_da>'
  endif
endfunction
augroup my-vim-template
  autocmd! *
  autocmd User plugin-template-loaded call s:template_keywords()
augroup END

