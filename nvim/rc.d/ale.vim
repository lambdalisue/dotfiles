" function! s:typescript_command_callback(buffer) abort
"   let tslint_config_path = ale#path#ResolveLocalPath(
"        \ a:buffer,
"        \ 'tslint.json',
"        \ ale#Var(a:buffer, 'typescript_tslint_config_path'),
"        \)
"   let tslint_config_option = !empty(tslint_config_path)
"        \ ? ' -c ' . ale#Escape(tslint_config_path)
"        \ : ''
"   let tslint_rules_dir = ale#Var(a:buffer, 'typescript_tslint_rules_dir')
"   let tslint_rules_option = !empty(tslint_rules_dir)
"        \ ? ' -r ' . ale#Escape(tslint_rules_dir)
"        \ : ''
"   return ale#handlers#tslint#GetExecutable(a:buffer)
"        \ . ' --format json'
"        \ . tslint_config_option
"        \ . tslint_rules_option
"        \ . ' %t'
" endfunction
"
"
" call ale#linter#Define('typescript', {
"      \ 'name': 'tslint-local',
"      \ 'executable_callback': 'ale#handlers#tslint#GetExecutable',
"      \ 'command_callback': get(funcref('s:typescript_command_callback'), 'name'),
"      \ 'callback': 'ale_linters#typescript#tslint#Handle',
"      \})


" let g:ale_fix_on_save = 1
let g:ale_linters = {
      \ 'python': ['mypy', 'flake8'],
      \}

let g:ale_fixers = {
      \ 'python': [
      \   'isort',
      \   'remove_trailing_lines',
      \   'trim_whitespace',
      \   'black',
      \ ],
      \ 'typescript': ['eslint', 'prettier', 'remove_trailing_lines', 'trim_whitespace'],
      \ 'javascript': ['eslint', 'prettier', 'remove_trailing_lines', 'trim_whitespace'],
      \}

let g:ale_linters_ignore = {
      \ 'typescript': ['tslint'],
      \}

" let g:ale_python_auto_pipenv = 1
