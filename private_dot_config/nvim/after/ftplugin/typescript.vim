setlocal foldmethod=syntax

" Automatically indent dot chained method calls
setlocal indentkeys+=0.

function! s:enable_deno() abort
  call coc#config('deno.enable', v:true)
  call coc#config('tsserver.enable', v:false)
  call coc#config('prettier.enable', v:false)
  call timer_start(0, { -> execute('silent! CocRestart') })
endfunction

function! s:enable_tsserver() abort
  call coc#config('deno.enable', v:false)
  call coc#config('tsserver.enable', v:true)
  call coc#config('prettier.enable', v:true)
  call timer_start(0, { -> execute('silent! CocRestart') })
endfunction

command! CocTypescriptOnDeno call s:enable_deno()
command! CocTypescriptOnTsserver call s:enable_tsserver()

function! s:switch_coc_typescript(bufname) abort
  if exists('g:my_coc_typescript_detected')
    return
  endif
  let g:my_coc_typescript_detected = 1
  let dir = a:bufname ==# '' ? '.' : fnamemodify(a:bufname, ':p:h')
  if !empty(findfile("deno.json", dir . ';'))
    call s:enable_deno()
  elseif !empty(findfile("package.json", dir . ';'))
    call s:enable_tsserver()
  else
    call s:enable_deno()
  endif
endfunction

if has('vim_starting')
  augroup my_coc
    autocmd!
    autocmd User CocNvimInit call s:switch_coc_typescript()
  augroup END
else
call s:switch_coc_typescript(expand('%'))
endif
