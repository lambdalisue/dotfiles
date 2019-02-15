if exists('g:loaded_largefile')
  finish
endif
let g:loaded_largefile = 1
let s:threshold = 10 * 1024 * 1024

augroup largefile_internal
  autocmd!
  autocmd BufReadPre * call s:BufReadPre()
augroup END

function! s:BufReadPre() abort
  let filename = expand('<afile>')
  if !filereadable(filename)
    return
  endif
  let fsize = getfsize(filename)
  if fsize < s:threshold
    return
  endif
  let b:cursorword = 0
  let b:parenmatch = 0
  let b:ale_enabled = 0
  echo printf("%s is too large")
endfunction
