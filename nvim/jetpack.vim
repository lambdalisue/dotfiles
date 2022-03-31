function! s:init() abort
  call s:ensure_jetpack()
  call jetpack#begin(expand('$VIMHOME'))
  call jetpack#add('tani/vim-jetpack', { 'opt': 1 })

  call jetpack#add('Shougo/ddu.vim')
  call jetpack#add('Shougo/ddu-ui-ff')
  call jetpack#add('Shougo/ddu-kind-file')
  call jetpack#add('Shougo/ddu-filter-matcher_substring')
  call jetpack#add('kuuote/ddu-source-mr')

  call jetpack#add('lambdalisue/askpass.vim')
  call jetpack#add('lambdalisue/gin.vim')
  call jetpack#add('vim-denops/denops.vim')
  call jetpack#add('yuki-yano/fuzzy-motion.vim')

  call jetpack#add('AndrewRadev/linediff.vim')
  call jetpack#add('Bakudankun/BackAndForward.vim')
  call jetpack#add('LumaKernel/fern-mapping-fzf.vim')
  call jetpack#add('Shougo/context_filetype.vim')
  call jetpack#add('Shougo/junkfile.vim')
  call jetpack#add('aiya000/aho-bakaup.vim')
  call jetpack#add('bluz71/vim-nightfly-guicolors')
  call jetpack#add('c000/rapidfire.vim')
  call jetpack#add('cocopon/colorswatch.vim')
  call jetpack#add('hrsh7th/vim-eft')
  call jetpack#add('itchyny/vim-parenmatch')
  call jetpack#add('junegunn/fzf', {'do': { -> fzf#install() }})
  call jetpack#add('junegunn/vim-emoji')
  call jetpack#add('kana/vim-altr')
  call jetpack#add('kana/vim-operator-replace')
  call jetpack#add('kana/vim-operator-user')
  call jetpack#add('kana/vim-repeat')
  call jetpack#add('kana/vim-textobj-indent')
  call jetpack#add('kana/vim-textobj-line')
  call jetpack#add('kana/vim-textobj-user')
  call jetpack#add('kuuote/gina-preview.vim')
  call jetpack#add('lambdalisue/battery.vim')
  call jetpack#add('lambdalisue/compl-local-filename.vim')
  call jetpack#add('lambdalisue/fern-bookmark.vim')
  call jetpack#add('lambdalisue/fern-comparator-lexical.vim')
  call jetpack#add('lambdalisue/fern-git-status.vim')
  call jetpack#add('lambdalisue/fern-hijack.vim')
  call jetpack#add('lambdalisue/fern-mapping-git.vim')
  call jetpack#add('lambdalisue/fern-mapping-mark-children.vim')
  call jetpack#add('lambdalisue/fern-mapping-project-top.vim')
  call jetpack#add('lambdalisue/fern-mapping-quickfix.vim')
  call jetpack#add('lambdalisue/fern-renderer-nerdfont.vim')
  call jetpack#add('lambdalisue/fern.vim')
  call jetpack#add('lambdalisue/fin-quickfix.vim')
  call jetpack#add('lambdalisue/fin.vim')
  call jetpack#add('lambdalisue/gina.vim')
  call jetpack#add('lambdalisue/glyph-palette.vim')
  call jetpack#add('lambdalisue/golangci-lint.vim')
  call jetpack#add('lambdalisue/grea.vim')
  call jetpack#add('lambdalisue/mr-quickfix.vim')
  call jetpack#add('lambdalisue/mr.vim')
  call jetpack#add('lambdalisue/nerdfont.vim')
  call jetpack#add('lambdalisue/pastefix.vim')
  call jetpack#add('lambdalisue/qfloc.vim')
  call jetpack#add('lambdalisue/readablefold.vim')
  call jetpack#add('lambdalisue/reword.vim')
  call jetpack#add('lambdalisue/seethrough.vim')
  call jetpack#add('lambdalisue/suda.vim')
  call jetpack#add('lambdalisue/trimmer.vim')
  call jetpack#add('lambdalisue/vim-backslash')
  call jetpack#add('lambdalisue/vim-findent')
  call jetpack#add('lambdalisue/vim-foldround')
  call jetpack#add('lambdalisue/vim-gista')
  call jetpack#add('lambdalisue/vim-manpager')
  call jetpack#add('lambdalisue/vim-marron')
  call jetpack#add('lambdalisue/vim-operator-breakline')
  call jetpack#add('lambdalisue/vim-quickrun-neovim-job')
  call jetpack#add('lambdalisue/vital-Data-String-Formatter')
  call jetpack#add('lambdalisue/vital-Whisky')
  call jetpack#add('lambdalisue/wifi.vim')
  call jetpack#add('machakann/vim-sandwich')
  call jetpack#add('mattn/vim-lexiv')
  call jetpack#add('mattn/vim-textobj-url')
  call jetpack#add('mattn/webapi-vim')
  call jetpack#add('mbbill/undotree')
  call jetpack#add('neoclide/coc.nvim', {'branch': 'release'})
  call jetpack#add('osyo-manga/vim-textobj-multiblock')
  call jetpack#add('powerman/vim-plugin-AnsiEsc')
  call jetpack#add('previm/previm')
  call jetpack#add('rbtnn/vim-vimscript_lasterror')
  call jetpack#add('sgur/vim-textobj-parameter')
  call jetpack#add('t9md/vim-quickhl')
  call jetpack#add('thinca/vim-prettyprint')
  call jetpack#add('thinca/vim-qfreplace')
  call jetpack#add('thinca/vim-quickrun')
  call jetpack#add('thinca/vim-template')
  call jetpack#add('thinca/vim-themis')
  call jetpack#add('thinca/vim-zenspace')
  call jetpack#add('tweekmonster/helpful.vim')
  call jetpack#add('tyru/capture.vim')
  call jetpack#add('tyru/caw.vim')
  call jetpack#add('tyru/current-func-info.vim')
  call jetpack#add('tyru/open-browser.vim')
  call jetpack#add('vim-jp/vimdoc-ja')
  call jetpack#add('vim-jp/vital-complete')
  call jetpack#add('vim-jp/vital.vim')
  call jetpack#add('will133/vim-dirdiff')
  call jetpack#add('yuki-yano/fern-preview.vim')

  " Colorscheme
  call jetpack#add('cocopon/iceberg.vim')

  " Optional
  call jetpack#add('rhysd/vim-healthcheck', {'opt': 1 })
  call jetpack#add('nvim-treesitter/nvim-treesitter', {'opt': 1 })
  call jetpack#end()
endfunction

function! s:local() abort
  for path in glob('~/ghq/github.com/*/*', 1, 1, 1)
    if isdirectory(path . '/autoload') || isdirectory(path . '/plugin')
      execute printf('set runtimepath^=%s', fnameescape(path))
    endif
  endfor
endfunction

function! s:configure() abort
  if has('nvim')
    silent packadd nvim-treesitter
  else
    silent packadd vim-healthcheck
  endif

  " Load plugin configurations
  call s:load_configurations()
  if has('nvim')
    call s:load_lua_configurations()
  endif
endfunction

function! s:ensure_jetpack() abort
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
