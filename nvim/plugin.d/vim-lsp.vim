function! s:on_lsp_buffer_enabled() abort
  setlocal completeopt-=preview
  setlocal foldmethod=expr foldexpr=lsp#ui#vim#folding#foldexpr()
  setlocal omnifunc=lsp#complete
  setlocal signcolumn=yes
  if exists('+tagfunc')
    setlocal tagfunc=lsp#tagfunc
  endif
  nmap <buffer> [[ <Plug>(lsp-previous-diagnostic)
  nmap <buffer> ]] <Plug>(lsp-next-diagnostic)

  nmap <buffer> gd <plug>(lsp-definition)
  nmap <buffer> gi <plug>(lsp-implementation)
  nmap <buffer> gy <plug>(lsp-type-definition)
  nmap <buffer> gr <plug>(lsp-references)
  nmap <buffer> <F2> <plug>(lsp-rename)

  nmap <buffer> K <plug>(lsp-hover)
endfunction

augroup lsp_install
  autocmd!
  autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

let g:lsp_preview_doubletap = []
