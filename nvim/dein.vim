set packpath=''

function! s:install() abort
  if !executable('git')
    echohl ErrorMsg
    echo '"git" is not executable. You need to install "git" first.'
    echohl None
    return
  endif

  let url = 'https://github.com/Shougo/dein.vim'
  let dst = expand('~/.cache/dein/repos/github.com/Shougo/dein.vim')
  " Create destination parent directory
  call mkdir(fnamemodify(dst, ':p:h'), 'p')
  " Clone the repository
  execute printf('!git clone %s %s', url, fnameescape(dst))
endfunction

command! Install call s:install()

let s:bundle_root = expand('~/.cache/dein')
let s:bundle_dein = s:bundle_root . '/repos/github.com/Shougo/dein.vim'
if isdirectory(s:bundle_dein)
  if has('vim_starting')
    execute 'set runtimepath^=' . fnameescape(s:bundle_dein)
  endif
  if dein#load_state(s:bundle_root)
    call dein#begin(s:bundle_root, [
          \ expand('$VIMHOME/init.vim'),
          \ expand('$VIMHOME/dein.vim'),
          \ expand('$VIMHOME/dein.toml'),
          \])
    call dein#load_toml(expand('$VIMHOME/dein.toml'))
    call dein#end()
    call dein#save_state()
  endif
  if has('vim_starting')
    call dein#call_hook('source')
    autocmd MyAutoCmd VimEnter * call dein#call_hook('post_source')
  else
    call dein#call_hook('source')
    call dein#call_hook('post_source')
  endif
endif

" Load plugin.d/*.vim {{{1
function! s:load_configurations() abort
  for path in glob('$VIMHOME/plugin.d/*.vim', 1, 1, 1)
    execute printf('source %s', fnameescape(path))
  endfor
endfunction
call s:load_configurations()
