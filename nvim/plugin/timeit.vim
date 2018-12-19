function! s:timeit(command) abort
  let start = reltime()
  execute a:command
  let delta = reltime(start)
  echomsg '[timeit]' a:command
  echomsg '[timeit]' reltimestr(delta)
endfunction

command! -nargs=* Timeit call s:timeit(<q-args>)
