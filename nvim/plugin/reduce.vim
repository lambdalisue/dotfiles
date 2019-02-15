if exists('g:loaded_reduce')
  finish
endif
let g:loaded_reduce = 1

augroup reduce_internal
  autocmd!
  autocmd BufReadPre * call s:reduce(expand('<afile>'), 0)
  autocmd User ReduceBufferPre  :
  autocmd User ReduceBufferPost :
augroup END

function! s:reduce(path, force) abort
  let path = expand(a:path)
  if !filereadable(path)
    return
  endif
  let fsize = getfsize(path)
  if fsize >= g:reduce_threshold
    doautocmd User ReduceBufferPre
    syntax clear
    let b:cursorword = 0
    let b:parenmatch = 0
    let b:ale_enabled = 0
    doautocmd User ReduceBufferPost
  endif
endfunction

let g:reduce_threshold = get(g:, 'reduce_threshold', 1 * 1024 * 1024)
