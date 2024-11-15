let g:denops#server#deno_args = ['-q', '--no-lock', '-A', '--unstable-ffi', '--unstable-kv']

function! s:interrupt() abort
  if quickrun#is_running()
    silent! call quickrun#sweep_sessions()
  endif
  silent! call denops#interrupt()
endfunction

" Interrupt the process of plugins via <C-c>
noremap <silent> <C-c> <Cmd>call <SID>interrupt()<CR><C-c>
inoremap <silent> <C-c> <Cmd>call <SID>interrupt()<CR><C-c>
cnoremap <silent> <C-c> <Cmd>call <SID>interrupt()<CR><C-c>
noremap <silent> <F12> <Cmd>call <SID>interrupt()<CR>
inoremap <silent> <F12> <Cmd>call <SID>interrupt()<CR>
cnoremap <silent> <F12> <Cmd>call <SID>interrupt()<CR>

" Restart Denops server
command! DenopsRestart call denops#server#restart()

" Fix Deno module cache issue
command! DenopsFixCache call denops#cache#update(#{reload: v:true})
