"let g:denops#debug = 1
"let g:denops#trace = ['skkeleton']
"let g:denops#server#deno_args = ['--no-lock', '--unstable', '-A', '--inspect']
"let g:denops#deno = expand('~/ghq/github.com/denoland/deno/target/release/deno')
if has('win32')
  let g:denops_server_addr = '127.0.0.1:32123'
endif

if filereadable(expand('~/.local/share/rtx/shims/deno'))
  let g:denops#deno = expand('~/.local/share/rtx/shims/deno')
endif
