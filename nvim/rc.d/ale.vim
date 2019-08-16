" Cache executable check for performance
let g:ale_cache_executable_check_failures = 1
" Use nice for any process of ALE
let g:ale_command_wrapper = executable('nice') ? 'nice' : ''

" Do NOT trigger ALE on TextChangedI
let g:ale_lint_on_text_changed = 'normal'
" Remove several builtin linters
let g:ale_linters_ignore = {
      \ 'python': ['pylint'],
      \ 'typescript': ['tslint'],
      \}
let g:ale_linters = {
      \ 'haskell': ['stack-build'],
      \}
let g:ale_fixers = {
      \ 'go': [
      \   'gofmt',
      \   'goimports',
      \   'remove_trailing_lines',
      \   'trim_whitespace',
      \ ],
      \ 'python': [
      \   'isort',
      \   'remove_trailing_lines',
      \   'trim_whitespace',
      \   'black',
      \ ],
      \ 'typescript': [
      \   'eslint',
      \   'prettier',
      \   'remove_trailing_lines',
      \   'trim_whitespace',
      \ ],
      \ 'javascript': [
      \   'eslint',
      \   'prettier',
      \   'remove_trailing_lines',
      \   'trim_whitespace',
      \ ],
      \ 'vue': [
      \   'prettier',
      \   'remove_trailing_lines',
      \   'trim_whitespace',
      \ ],
      \ 'css': [
      \   'prettier',
      \   'remove_trailing_lines',
      \   'trim_whitespace',
      \ ],
      \ 'scss': [
      \   'prettier',
      \   'remove_trailing_lines',
      \   'trim_whitespace',
      \ ],
      \ 'html': [
      \   'prettier',
      \   'remove_trailing_lines',
      \   'trim_whitespace',
      \ ],
      \}
let g:ale_fix_on_save = 1

" Disable signs for performance
let g:ale_set_signs = 0
let g:ale_echo_cursor = 0

command! ALEFixerEnable let g:ale_fix_on_save = 1
command! ALEFixerDisable let g:ale_fix_on_save = 0
