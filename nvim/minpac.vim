let s:script = expand("<sfile>")

function! s:init() abort
  call s:ensure_minpac()

  call minpac#init()
  call minpac#add('k-takata/minpac', {'type': 'opt'})

  call minpac#add('Shougo/ddu.vim')
  call minpac#add('Shougo/ddu-ui-ff')
  call minpac#add('Shougo/ddu-kind-file')
  call minpac#add('Shougo/ddu-filter-matcher_substring')
  call minpac#add('kuuote/ddu-source-mr')

  call minpac#add('lambdalisue/askpass.vim')
  call minpac#add('lambdalisue/gin.vim')
  call minpac#add('vim-denops/denops.vim')
  call minpac#add('yuki-yano/fuzzy-motion.vim')

  call minpac#add('AndrewRadev/linediff.vim')
  call minpac#add('Bakudankun/BackAndForward.vim')
  call minpac#add('LumaKernel/fern-mapping-fzf.vim')
  call minpac#add('Shougo/context_filetype.vim')
  call minpac#add('Shougo/junkfile.vim')
  call minpac#add('aiya000/aho-bakaup.vim')
  call minpac#add('bluz71/vim-nightfly-guicolors')
  call minpac#add('c000/rapidfire.vim')
  call minpac#add('cocopon/colorswatch.vim')
  call minpac#add('hrsh7th/vim-eft')
  call minpac#add('itchyny/vim-parenmatch')
  call minpac#add('junegunn/fzf', {'do': { -> fzf#install() }})
  call minpac#add('junegunn/vim-emoji')
  call minpac#add('kana/vim-altr')
  call minpac#add('kana/vim-operator-replace')
  call minpac#add('kana/vim-operator-user')
  call minpac#add('kana/vim-repeat')
  call minpac#add('kana/vim-textobj-indent')
  call minpac#add('kana/vim-textobj-line')
  call minpac#add('kana/vim-textobj-user')
  call minpac#add('kuuote/gina-preview.vim')
  call minpac#add('lambdalisue/battery.vim')
  call minpac#add('lambdalisue/compl-local-filename.vim')
  call minpac#add('lambdalisue/fern-bookmark.vim')
  call minpac#add('lambdalisue/fern-comparator-lexical.vim')
  call minpac#add('lambdalisue/fern-git-status.vim')
  call minpac#add('lambdalisue/fern-hijack.vim')
  call minpac#add('lambdalisue/fern-mapping-git.vim')
  call minpac#add('lambdalisue/fern-mapping-mark-children.vim')
  call minpac#add('lambdalisue/fern-mapping-project-top.vim')
  call minpac#add('lambdalisue/fern-mapping-quickfix.vim')
  call minpac#add('lambdalisue/fern-renderer-nerdfont.vim')
  call minpac#add('lambdalisue/fern.vim')
  call minpac#add('lambdalisue/fin-quickfix.vim')
  call minpac#add('lambdalisue/fin.vim')
  call minpac#add('lambdalisue/gina.vim')
  call minpac#add('lambdalisue/glyph-palette.vim')
  call minpac#add('lambdalisue/golangci-lint.vim')
  call minpac#add('lambdalisue/grea.vim')
  call minpac#add('lambdalisue/mr-quickfix.vim')
  call minpac#add('lambdalisue/mr.vim')
  call minpac#add('lambdalisue/nerdfont.vim')
  call minpac#add('lambdalisue/pastefix.vim')
  call minpac#add('lambdalisue/qfloc.vim')
  call minpac#add('lambdalisue/readablefold.vim')
  call minpac#add('lambdalisue/reword.vim')
  call minpac#add('lambdalisue/seethrough.vim')
  call minpac#add('lambdalisue/suda.vim')
  call minpac#add('lambdalisue/trimmer.vim')
  call minpac#add('lambdalisue/vim-backslash')
  call minpac#add('lambdalisue/vim-findent')
  call minpac#add('lambdalisue/vim-foldround')
  call minpac#add('lambdalisue/vim-gista')
  call minpac#add('lambdalisue/vim-manpager')
  call minpac#add('lambdalisue/vim-marron')
  call minpac#add('lambdalisue/vim-operator-breakline')
  call minpac#add('lambdalisue/vim-quickrun-neovim-job')
  call minpac#add('lambdalisue/vital-Data-String-Formatter')
  call minpac#add('lambdalisue/vital-Whisky')
  call minpac#add('lambdalisue/wifi.vim')
  call minpac#add('machakann/vim-sandwich')
  call minpac#add('mattn/vim-lexiv')
  call minpac#add('mattn/vim-textobj-url')
  call minpac#add('mattn/webapi-vim')
  call minpac#add('mbbill/undotree')
  call minpac#add('neoclide/coc.nvim', {'branch': 'release'})
  call minpac#add('osyo-manga/vim-textobj-multiblock')
  call minpac#add('powerman/vim-plugin-AnsiEsc')
  call minpac#add('previm/previm')
  call minpac#add('rbtnn/vim-vimscript_lasterror')
  call minpac#add('sgur/vim-textobj-parameter')
  call minpac#add('t9md/vim-quickhl')
  call minpac#add('thinca/vim-prettyprint')
  call minpac#add('thinca/vim-qfreplace')
  call minpac#add('thinca/vim-quickrun')
  call minpac#add('thinca/vim-template')
  call minpac#add('thinca/vim-themis')
  call minpac#add('thinca/vim-zenspace')
  call minpac#add('tweekmonster/helpful.vim')
  call minpac#add('tyru/capture.vim')
  call minpac#add('tyru/caw.vim')
  call minpac#add('tyru/current-func-info.vim')
  call minpac#add('tyru/open-browser.vim')
  call minpac#add('vim-jp/vimdoc-ja')
  call minpac#add('vim-jp/vital-complete')
  call minpac#add('vim-jp/vital.vim')
  call minpac#add('will133/vim-dirdiff')
  call minpac#add('yuki-yano/fern-preview.vim')

  " Colorscheme
  call minpac#add('cocopon/iceberg.vim')

  " Optional
  call minpac#add('rhysd/vim-healthcheck', {'type': 'opt'})
  call minpac#add('nvim-treesitter/nvim-treesitter', {'type': 'opt'})
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

function! s:ensure_minpac() abort
  let url = 'https://github.com/k-takata/minpac'
  let dir = expand('$VIMHOME/pack/minpac/opt/minpac')
  if !isdirectory(dir)
    silent execute printf('!git clone --depth 1 %s %s', url, dir)
  endif
  packadd minpac
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

call s:configure()
command! PackUpdate call s:init() | call minpac#update()
command! PackClean  call s:init() | call minpac#clean()
command! PackStatus packadd minpac | call minpac#status()
