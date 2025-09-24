let g:quickrun_config = extend(get(g:, 'quickrun_config', {}), {
      \ '_': {
      \   'outputter/buffer/split': ':botright 8sp',
      \   'outputter/buffer/close_on_empty': 1,
      \   'hook/time/enable': 1,
      \ },
      \ 'pyrex': {
      \   'command': 'cython',
      \ },
      \ 'perl': {
      \   'command': 'carton',
      \   'cmdopt': '-Ilib',
      \   'exec': '%c exec perl %o %s',
      \ },
      \ 'ps1': {
      \   'command': 'powershell',
      \ },
      \ 'javascript': {
      \   'command': 'deno',
      \   'cmdopt': '--allow-all --unstable-ffi --unstable-temporal --unstable-kv',
      \   'exec': 'NO_COLOR=1 %c run %o %s',
      \ },
      \ 'typescript': {
      \   'command': 'deno',
      \   'cmdopt': '--allow-all --unstable-ffi --unstable-temporal --unstable-kv',
      \   'exec': 'NO_COLOR=1 %c run %o %s',
      \ },
      \ 'typescriptreact': {
      \   'command': 'deno',
      \   'cmdopt': '--allow-all --unstable-ffi --unstable-temporal --unstable-kv',
      \   'exec': 'NO_COLOR=1 %c run %o %s',
      \ },
      \})

if has('nvim')
  let g:quickrun_config._.runner = 'neovim_job'
elseif exists('*ch_close_in')
  let g:quickrun_config._.runner = 'job'
endif

nmap <Leader>rr <Plug>(quickrun)
