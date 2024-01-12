"let g:denops#debug = 1
"let g:denops#server#deno_args = ['--no-lock', '--unstable', '-A', '--inspect']
"let g:denops_server_addr = '127.0.0.1:32123'

if has('win32')
  let g:denops_server_addr = '127.0.0.1:32123'
endif
