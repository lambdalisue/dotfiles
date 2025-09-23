function! s:init() abort
  call s:ensure()
  call jetpack#begin()
  call jetpack#add('tani/vim-jetpack')

  " NerdFont
  " call jetpack#add('ryanoasis/vim-devicons')
  " call jetpack#add('nvim-tree/nvim-web-devicons')

  " FuzzyFinder
  " call jetpack#add('vim-scripts/L9')
  " call jetpack#add('vim-scripts/FuzzyFinder')
  " call jetpack#add('Shougo/unite.vim')
  " call jetpack#add('ctrlpvim/ctrlp.vim')
  " call jetpack#add('junegunn/fzf', #{ do: { -> fzf#install() } })
  " call jetpack#add('junegunn/fzf.vim')
  " call jetpack#add('Shougo/denite.nvim')
  " call jetpack#add('yuki-yano/fzf-preview.vim', #{ branch: 'release/rpc' })
  " call jetpack#add('nvim-telescope/telescope.nvim')
  " call jetpack#add('Shougo/ddu.vim')

  " Denops
  "call jetpack#add('yuki-yano/fuzzy-motion.vim')
  call jetpack#add('lambdalisue/vim-askpass')
  call jetpack#add('lambdalisue/vim-deno-cache')
  call jetpack#add('lambdalisue/vim-gin')
  call jetpack#add('lambdalisue/vim-guise')
  call jetpack#add('lambdalisue/vim-initial')
  call jetpack#add('lambdalisue/vim-kensaku')
  call jetpack#add('skanehira/denops-silicon.vim')
  call jetpack#add('vim-denops/denops-shared-server.vim')
  call jetpack#add('vim-denops/denops-startup-recorder.vim')
  call jetpack#add('vim-denops/denops.vim')
  call jetpack#add('vim-fall/fall.vim')
  call jetpack#add('vim-skk/skkeleton')
  call jetpack#add('Shougo/ddc.vim')
  call jetpack#add('Shougo/ddc-ui-native')
  call jetpack#add('Shougo/ddc-matcher_head')
  call jetpack#add('Shougo/ddc-sorter_rank')

  " Colorscheme
  call jetpack#add('AndrewRadev/linediff.vim')
  call jetpack#add('Bakudankun/BackAndForward.vim')
  call jetpack#add('EdenEast/nightfox.nvim')
  call jetpack#add('Shougo/context_filetype.vim')
  call jetpack#add('Shougo/junkfile.vim')
  call jetpack#add('catppuccin/vim')
  call jetpack#add('cocopon/colorswatch.vim')
  call jetpack#add('cocopon/iceberg.vim')
  call jetpack#add('dstein64/vim-startuptime')
  call jetpack#add('github/copilot.vim')
  call jetpack#add('hrsh7th/vim-eft')
  call jetpack#add('itchyny/vim-parenmatch')
  call jetpack#add('itchyny/vim-qfedit')
  call jetpack#add('kana/vim-operator-replace')
  call jetpack#add('kana/vim-operator-user')
  call jetpack#add('kana/vim-repeat')
  call jetpack#add('kana/vim-textobj-indent')
  call jetpack#add('kana/vim-textobj-line')
  call jetpack#add('kana/vim-textobj-user')
  call jetpack#add('lambdalisue/vim-backslash')
  call jetpack#add('lambdalisue/vim-battery')
  call jetpack#add('lambdalisue/vim-compl-local-filename')
  call jetpack#add('lambdalisue/vim-fern')
  call jetpack#add('lambdalisue/vim-fern-git-status')
  call jetpack#add('lambdalisue/vim-fern-hijack')
  call jetpack#add('lambdalisue/vim-fern-mapping-git')
  call jetpack#add('lambdalisue/vim-fern-mapping-mark-children')
  call jetpack#add('lambdalisue/vim-fern-mapping-project-top')
  call jetpack#add('lambdalisue/vim-fern-mapping-quickfix')
  call jetpack#add('lambdalisue/vim-fern-renderer-nerdfont')
  call jetpack#add('lambdalisue/vim-file-protocol')
  call jetpack#add('lambdalisue/vim-findent')
  call jetpack#add('lambdalisue/vim-gina')
  call jetpack#add('lambdalisue/vim-glyph-palette')
  call jetpack#add('lambdalisue/vim-http-protocol')
  call jetpack#add('lambdalisue/vim-improved-gf')
  call jetpack#add('lambdalisue/vim-mr')
  call jetpack#add('lambdalisue/vim-nerdfont')
  call jetpack#add('lambdalisue/vim-operator-breakline')
  call jetpack#add('lambdalisue/vim-quickrun-neovim-job')
  call jetpack#add('lambdalisue/vim-readablefold')
  call jetpack#add('lambdalisue/vim-suda')
  call jetpack#add('lambdalisue/vim-trimmer')
  call jetpack#add('lambdalisue/vim-wifi')
  call jetpack#add('machakann/vim-sandwich')
  call jetpack#add('machakann/vim-swap')
  call jetpack#add('machakann/vim-textobj-delimited')
  call jetpack#add('mattn/vim-textobj-url')
  call jetpack#add('mattn/webapi-vim')
  call jetpack#add('mbbill/undotree')
  call jetpack#add('neo4j-contrib/cypher-vim-syntax')
  call jetpack#add('neoclide/coc.nvim', {'branch': 'release'})
  call jetpack#add('osyo-manga/vim-textobj-multiblock')
  call jetpack#add('previm/previm')
  call jetpack#add('rbtnn/vim-vimscript_lasterror')
  call jetpack#add('sgur/vim-textobj-parameter')
  call jetpack#add('t9md/vim-quickhl')
  call jetpack#add('tani/dmacro.nvim')
  call jetpack#add('thinca/vim-qfreplace')
  call jetpack#add('thinca/vim-quickrun')
  call jetpack#add('thinca/vim-template')
  call jetpack#add('thinca/vim-themis')
  call jetpack#add('thinca/vim-zenspace')
  call jetpack#add('tweekmonster/helpful.vim')
  call jetpack#add('tyru/capture.vim')
  call jetpack#add('tyru/open-browser.vim')
  call jetpack#add('will133/vim-dirdiff')

  " Vim
  if !has('nvim')
    call jetpack#add('rhysd/vim-healthcheck', {'opt': 1 })
    call jetpack#add('mattn/vim-lexiv', {'opt': 1})
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
    call jetpack#add('MeanderingProgrammer/markdown.nvim', {'opt': 1})
    call jetpack#add('delphinus/skkeleton_indicator.nvim', {'opt': 1})
    call jetpack#add('CopilotC-Nvim/CopilotChat.nvim', {'opt': 1})
    call jetpack#add("rcarriga/nvim-notify", {'opt': 1})
  endif

  call jetpack#end()
endfunction

function! s:local() abort
  let excludes = [
        \ 'denops-massive-plugins-tester',
        \]
  let proves = ['/autoload', '/plugin', '/ftplugin', '/denops', '/lua']
  for path in glob('~/ogh/*/*', 1, 1, 1)
    for prove in proves
      if isdirectory(path . prove) && index(excludes, fnamemodify(path, ':t')) is# -1
        execute printf('set runtimepath^=%s', fnameescape(path))
        break
      endif
    endfor
  endfor
endfunction

function! s:configure() abort
  if has('nvim')
    silent! packadd plenary.nvim
    silent! packadd nvim-treesitter
    silent! packadd nvim-insx
    silent! packadd Comment.nvim
    silent! packadd markdown.nvim
    silent! packadd skkeleton_indicator.nvim
    silent! packadd CopilotChat.nvim
    silent! packadd nvim-notify
  else
    silent! packadd vim-healthcheck
    silent! packadd vim-lexiv
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
