let g:neomake_ft_maker_remove_invalid_entries = 1
let g:neomake_error_sign = {
      \ 'text': 'x',
      \ 'texthl': 'Error'
      \}
let g:neomake_warning_sign = {
      \ 'text': '!',
      \ 'texthl': 'Todo'
      \}
let g:neomake_info_sign = {
      \ 'text': 'i',
      \ 'texthl': 'Type'
      \}
let g:neomake_message_sign = {
      \ 'text': '>',
      \ 'texthl': 'Comment'
      \}

let g:neomake_typescript_enabled_makers = []
let g:neomake_python_enabled_makers = [
      \ 'python',
      \ 'flake8',
      \ 'mypy'
      \]

let g:neomake_eslint_maker = extend(neomake#makers#ft#vue#eslint(), {
      \ 'exe': 'eslint',
      \ 'args': ['-f', 'compact', '--ignore-pattern', '!%'],
      \})

function! s:configure_eslint() abort
  if exists('b:neomake_eslint_exe')
    return
  endif
  let eslint = findfile('node_modules/.bin/eslint', '.;')
  let eslint = empty(eslint) ? 'eslint' : fnamemodify(eslint, ':p')
  let b:neomake_eslint_exe = eslint
endfunction

augroup my_neomake
  autocmd! *
  autocmd FileReadPost * Neomake
  autocmd BufWritePost * Neomake
  if exists('g:loaded_lightline')
    autocmd User NeomakeFinished nested call lightline#update()
  endif
augroup END

augroup my_neomake_buffer_local
  autocmd! *
  autocmd BufEnter setup.py let b:neomake_python_enabled_markers = ['python']
  autocmd BufEnter docs/conf.py let b:neomake_python_enabled_markers = ['python']
  autocmd FileType vue,javascript call s:configure_eslint()
augroup END

