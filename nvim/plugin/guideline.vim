if exists('g:loaded_guideline')
  finish
endif
let g:loaded_guideline = 1


function! s:enable_guide() abort
  if exists('w:guideline_explicit_cursurline')
    return
  endif
  noautocmd setlocal cursorline

  augroup guideline-buffer-internal
    autocmd! * <buffer>
    autocmd CursorMoved,CursorMovedI,WinLeave <buffer> ++once noautocmd setlocal nocursorline
  augroup END
endfunction

function! s:OptionSet() abort
  if v:option_type !=# 'local'
    return
  endif
  let w:guideline_explicit_cursorline = 1
endfunction

augroup guideline-internal
  autocmd!
  autocmd CursorHold,CursorHoldI,WinEnter * call timer_start(0, { -> s:enable_guide() })
  autocmd OptionSet cursorline call s:OptionSet()
augroup END
