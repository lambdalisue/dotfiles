let g:quickrun_config = extend(get(g:, 'quickrun_config', {}), {
      \ '_': {
      \   'runner/job/interval': 200,
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
      \   'runner': 'system',
      \   'command': 'powershell',
      \ }
      \})

if exists('*ch_close_in')
  let g:quickrun_config._.runner = 'job'
endif

" Terminate the quickrun with <C-c>
nnoremap <expr><silent> <C-c> quickrun#is_running()
      \ ? quickrun#sweep_sessions()
      \ : "\<C-c>"
