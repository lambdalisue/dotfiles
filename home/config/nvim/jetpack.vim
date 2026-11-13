function! s:init() abort
  call s:ensure()
  call jetpack#begin()
  call jetpack#add('tani/vim-jetpack')

  call jetpack#add('AndrewRadev/linediff.vim')
  call jetpack#add('EdenEast/nightfox.nvim')
  call jetpack#add('Makaze/AnsiEsc')
  call jetpack#add('arto-app/vim-arto')
  call jetpack#add('lambdalisue/vim-battery')
  call jetpack#add('lambdalisue/vim-compl-local-filename')
  call jetpack#add('lambdalisue/vim-fern')
  call jetpack#add('lambdalisue/vim-fern-git-status')
  call jetpack#add('lambdalisue/vim-fern-hijack')
  call jetpack#add('lambdalisue/vim-fern-mapping-git')
  call jetpack#add('lambdalisue/vim-fern-mapping-mark-children')
  call jetpack#add('lambdalisue/vim-fern-mapping-project-top')
  call jetpack#add('lambdalisue/vim-fern-renderer-nerdfont')
  call jetpack#add('lambdalisue/vim-file-protocol')
  call jetpack#add('lambdalisue/vim-glyph-palette')
  call jetpack#add('lambdalisue/vim-guise')
  call jetpack#add('lambdalisue/vim-http-protocol')
  call jetpack#add('lambdalisue/vim-improved-gf')
  call jetpack#add('lambdalisue/vim-lese')
  call jetpack#add('lambdalisue/vim-lese-mr')
  call jetpack#add('lambdalisue/vim-mr')
  call jetpack#add('lambdalisue/vim-nerdfont')
  call jetpack#add('lambdalisue/vim-readablefold')
  call jetpack#add('lambdalisue/vim-suda')
  call jetpack#add('lambdalisue/vim-trimmer')
  call jetpack#add('lambdalisue/vim-wifi')
  call jetpack#add('thinca/vim-themis')
  call jetpack#add('thinca/vim-zenspace')
  call jetpack#add('tyru/capture.vim')
  call jetpack#add('tyru/open-browser.vim')

  " Vim
  if !has('nvim')
    call jetpack#add('rhysd/vim-healthcheck', {'opt': 1 })
    call jetpack#add('tyru/caw.vim', {'opt': 1})
  endif

  " Neovim
  if has('nvim')
    call jetpack#add('nvim-lua/plenary.nvim', {'opt': 1})
    call jetpack#add('nvim-treesitter/nvim-treesitter', {
        \ 'opt': 1,
        \ 'do': { -> execute('silent! packadd nvim-treesitter | TSUpdate') },
        \})
    call jetpack#add('hrsh7th/nvim-insx', {'opt': 1})
    call jetpack#add('numToStr/Comment.nvim', {'opt': 1})
    call jetpack#add("rcarriga/nvim-notify", {'opt': 1})
    call jetpack#add("lambdalisue/nvim-aibo", {'opt': 1})
  endif

  call jetpack#end()
endfunction

function! s:local() abort
  let excludes = [
        \ 'denops-massive-plugins-tester',
        \]
  let proves = ['/autoload', '/plugin', '/ftplugin', '/denops', '/lua']
  for path in glob('~/ghq/github.com/*/*', 1, 1, 1)
    for prove in proves
      if isdirectory(path . prove) && index(excludes, fnamemodify(path, ':t')) is# -1
        execute printf('set runtimepath^=%s', fnameescape(path))
        break
      endif
    endfor
  endfor
  "set runtimepath^=.
endfunction

function! s:configure() abort
  if has('nvim')
    silent! packadd plenary.nvim
    silent! packadd nvim-treesitter
    silent! packadd Comment.nvim
    silent! packadd nvim-notify
    silent! packadd nvim-aibo
  else
    silent! packadd vim-healthcheck
  endif

  " Load plugin configurations
  call s:load_configurations()
  if has('nvim')
    call s:load_lua_configurations()
  endif
endfunction

function! s:ensure() abort
  let url = 'https://github.com/tani/vim-jetpack'
  let dir = expand('$VIMHOME/pack/jetpack/opt/vim-jetpack')
  if !isdirectory(dir)
    silent execute printf('!git clone --depth 1 %s %s', url, dir)
  endif
  packadd vim-jetpack
endfunction

function! s:load_configurations() abort
  for path in glob('$VIMHOME/plugin.d/*.vim', 1, 1, 1)
    execute printf('source %s', fnameescape(path))
  endfor
endfunction

function! s:load_lua_configurations() abort
  for path in glob('$VIMHOME/plugin.d/*.lua', 1, 1, 1)
    execute printf('luafile %s', fnameescape(path))
  endfor
endfunction

call s:init()
call s:local()
call s:configure()
