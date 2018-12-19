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
