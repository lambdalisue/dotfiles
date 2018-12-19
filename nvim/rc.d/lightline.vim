function! s:readonly() abort
  return &l:readonly ? 'x' : ''
endfunction

function! s:datetime() abort
  return strftime('%a %m/%d %H:%M')
endfunction

function! s:pyvenv() abort
  if !exists('g:loaded_pyvenv')
    return ''
  endif
  return pyenv#component()
endfunction

function! s:gina() abort
  if !exists('g:loaded_gina')
    return ''
  endif
  let components = [
        \ gina#component#repo#preset('fancy'),
        \ gina#component#status#preset('fancy'),
        \ gina#component#traffic#preset('fancy'),
        \]
  return join(filter(components, '!empty(v:val)'), ' | ')
endfunction

function! s:info() abort
  if &buftype =~# '\%(nofile\|quickfix\|help\)'
    return ''
  elseif &buftype ==# 'terminal'
    return 'Hit <C-\><C-n> to escape'
  else
    let info = printf(
          \ '%s | %s | %s',
          \ &l:fileformat,
          \ &l:fileencoding ==# '' ? &encoding : &l:fileencoding,
          \ &l:filetype ==# '' ? 'no ft' : &l:filetype,
          \)
    return substitute(info, '%', '%%', 'g')
  endif
endfunction


let g:lightline = {
      \ 'colorscheme': 'iceberg',
      \ 'mode_map': {
      \   'n' : ' ',
      \   'i' : ' ',
      \   'R' : ' ',
      \   'v' : ' ',
      \   'V' : ' ',
      \   "\<C-v>": ' ',
      \   'c' : ' ',
      \   's' : ' ',
      \   'S' : ' ',
      \   "\<C-s>": ' ',
      \   't': ' ',
      \ }
      \}

let g:lightline.active = {
      \ 'left': [
      \   ['mode', 'paste'],
      \   ['readonly'],
      \   ['modified'],
      \   ['relativepath'],
      \ ],
      \ 'right': [
      \   ['locationlist'],
      \   ['info'],
      \ ],
      \}

let g:lightline.inactive = {
      \ 'left': [
      \   ['relativepath'],
      \ ],
      \ 'right': [
      \   ['filetype'],
      \ ],
      \}

let g:lightline.tabline = {
      \ 'left': [
      \   ['cwd'],
      \   ['tabs'],
      \ ],
      \ 'right': [
      \   ['quickfix'],
      \   ['wifi', 'battery', 'datetime'],
      \   ['gina'],
      \   ['pyvenv'],
      \ ],
      \}

let g:lightline.component = {
      \ 'cwd': '%{fnamemodify(getcwd(), '':~'')}',
      \}

let g:lightline.component_raw = {
      \ 'mode': 1,
      \}

let g:lightline.component_type = {
      \ 'readonly': 'warning',
      \ 'quickfix': 'error',
      \ 'locationlist': 'error',
      \}

let g:lightline.component_expand = {
      \ 'readonly': get(function('s:readonly'), 'name'),
      \ 'pyvenv': get(function('s:pyvenv'), 'name'),
      \ 'gina': get(function('s:gina'), 'name'),
      \ 'quickfix': 'neomake#statusline#QflistStatus',
      \ 'locationlist': 'neomake#statusline#LoclistStatus',
      \}

let g:lightline.component_function = {
      \ 'datetime': get(function('s:datetime'), 'name'),
      \ 'info': get(function('s:info'), 'name'),
      \ 'wifi': 'wifi#component',
      \ 'battery': 'battery#component',
      \}

if !has('vim_starting')
  call lightline#init()
  call lightline#colorscheme()
  call lightline#update()
endif

if !exists('s:timer')
  let s:timer = timer_start(30000, { timer -> lightline#update() }, { 'repeat': -1 })
endif
