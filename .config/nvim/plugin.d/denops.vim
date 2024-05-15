"let g:denops#debug = 1
"let g:denops_server_addr = '127.0.0.1:32123'
let g:denops#server#deno_args = ['-q', '--no-lock', '-A', '--unstable-ffi']
"let g:denops#server#deno_args = ['-q', '--no-lock', '-A', '--unstable-ffi', '--inspect']

if has('win32')
  let g:denops_server_addr = '127.0.0.1:32123'
endif
