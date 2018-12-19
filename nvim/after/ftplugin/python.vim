" PEP8 Indent rules

setl tabstop=8        " width of TAB should be 8 characters
setl softtabstop=4    " 4 continuous spaces are assumed as Soft tab
setl shiftwidth=4     " width of Indent
setl smarttab         " use 'shiftwidth' and 'softtabstop' for indentation
setl expandtab        " use continuous spaces as TAB

" Indent rules should be overwritten by plugin
" https://github.com/hynek/vim-python-pep8-indent
"setl autoindent           " copy inent leven from previous line
"setl nosmartindent        " do not use smartindent, indent after # will be suck
"setl cindent              " use cindent instead of smartindent and autoindent
"setl cinwords=if,elif,else,for,while,try,except,finally,def,class,with

" Folding should follow indent rules
"setl foldmethod=indent


function! s:open_pypi(word) abort
  let baseurl = 'https://pypi.python.org/pypi/%s'
  call openbrowser#open(printf(baseurl, a:word))
endfunction

nnoremap <buffer><silent> <Plug>(my-python-pypi) :<C-u>call <SID>open_pypi(expand('<cWORD>'))<CR>
nmap <buffer> gK <Plug>(my-python-pypi)

function! s:isort() abort
  function! s:on_then(result) abort
    let [result, options] = a:result
    if !&modified && bufnr('%') is# options.bufnr
      silent edit
    endif
  endfunction

  if executable('isort')
    call ake#ake(['isort', expand('%')], { 'ake_silent': v:true })
          \.then(funcref('s:on_then'))
  endif
endfunction
command! -buffer Isort call s:isort()
