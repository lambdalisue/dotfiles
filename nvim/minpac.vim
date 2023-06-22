function! s:init() abort
  call s:ensure_minpac()
  call minpac#init()
  call minpac#add('k-takata/minpac', { 'type': 'opt' })

  " ddu
  call minpac#add('Bakudankun/ddu-filter-matchfuzzy')
  call minpac#add('Milly/ddu-filter-kensaku')
  call minpac#add('Milly/ddu-filter-merge')
  call minpac#add('Shougo/ddu-column-filename')
  call minpac#add('Shougo/ddu-commands.vim')
  call minpac#add('Shougo/ddu-filter-matcher_substring')
  call minpac#add('Shougo/ddu-filter-sorter_alpha')
  call minpac#add('Shougo/ddu-filter-sorter_reversed')
  call minpac#add('Shougo/ddu-kind-file')
  call minpac#add('Shougo/ddu-kind-word')
  call minpac#add('Shougo/ddu-source-action')
  call minpac#add('Shougo/ddu-source-file')
  call minpac#add('Shougo/ddu-source-file_rec')
  call minpac#add('Shougo/ddu-source-line')
  call minpac#add('Shougo/ddu-source-register')
  call minpac#add('Shougo/ddu-ui-ff')
  call minpac#add('Shougo/ddu.vim')
  call minpac#add('kuuote/ddu-source-mr')
  call minpac#add('matsui54/ddu-source-command_history')
  call minpac#add('matsui54/ddu-source-help')
  call minpac#add('matsui54/ddu-vim-ui-select')
  call minpac#add('mikanIchinose/ddu-source-markdown')
  call minpac#add('tennashi/ddu-source-docbase')

  " Denops
  " call minpac#add('skanehira/denops-silicon.vim')
  call minpac#add('Shougo/dda.vim')
  call minpac#add('lambdalisue/askpass.vim')
  call minpac#add('lambdalisue/gin.vim')
  call minpac#add('lambdalisue/guise.vim')
  call minpac#add('lambdalisue/kensaku.vim')
  call minpac#add('skanehira/denops-translate.vim')
  call minpac#add('tani/hey.vim')
  call minpac#add('vim-denops/denops-shared-server.vim')
  call minpac#add('vim-denops/denops.vim')
  call minpac#add('yuki-yano/fuzzy-motion.vim')

  call minpac#add('AndrewRadev/linediff.vim')
  call minpac#add('Bakudankun/BackAndForward.vim')
  call minpac#add('Shougo/context_filetype.vim')
  call minpac#add('Shougo/junkfile.vim')
  call minpac#add('Vimjas/vim-python-pep8-indent')
  call minpac#add('aiya000/aho-bakaup.vim')
  call minpac#add('bluz71/vim-moonfly-colors')
  call minpac#add('bluz71/vim-nightfly-colors')
  call minpac#add('bluz71/vim-nightfly-guicolors')
  call minpac#add('c000/rapidfire.vim')
  call minpac#add('cocopon/colorswatch.vim')
  call minpac#add('dstein64/vim-startuptime')
  call minpac#add('github/copilot.vim')
  call minpac#add('hrsh7th/vim-eft')
  call minpac#add('itchyny/vim-parenmatch')
  call minpac#add('kana/vim-operator-replace')
  call minpac#add('kana/vim-operator-user')
  call minpac#add('kana/vim-repeat')
  call minpac#add('kana/vim-textobj-indent')
  call minpac#add('kana/vim-textobj-line')
  call minpac#add('kana/vim-textobj-user')
  call minpac#add('kevinhwang91/nvim-bqf')
  call minpac#add('lambdalisue/battery.vim')
  call minpac#add('lambdalisue/compl-local-filename.vim')
  call minpac#add('lambdalisue/fern-git-status.vim')
  call minpac#add('lambdalisue/fern-hijack.vim')
  call minpac#add('lambdalisue/fern-mapping-git.vim')
  call minpac#add('lambdalisue/fern-mapping-mark-children.vim')
  call minpac#add('lambdalisue/fern-mapping-project-top.vim')
  call minpac#add('lambdalisue/fern-mapping-quickfix.vim')
  call minpac#add('lambdalisue/fern-renderer-nerdfont.vim')
  call minpac#add('lambdalisue/fern.vim')
  call minpac#add('lambdalisue/file-protocol.vim')
  call minpac#add('lambdalisue/gina.vim')
  call minpac#add('lambdalisue/glyph-palette.vim')
  call minpac#add('lambdalisue/mr.vim')
  call minpac#add('lambdalisue/nerdfont.vim')
  call minpac#add('lambdalisue/readablefold.vim')
  call minpac#add('lambdalisue/suda.vim')
  call minpac#add('lambdalisue/trimmer.vim')
  call minpac#add('lambdalisue/vim-backslash')
  call minpac#add('lambdalisue/vim-findent')
  call minpac#add('lambdalisue/vim-manpager')
  call minpac#add('lambdalisue/vim-operator-breakline')
  call minpac#add('lambdalisue/vim-quickrun-neovim-job')
  call minpac#add('lambdalisue/wifi.vim')
  call minpac#add('machakann/vim-sandwich')
  call minpac#add('mattn/vim-textobj-url')
  call minpac#add('mattn/webapi-vim')
  call minpac#add('mbbill/undotree')
  call minpac#add('neoclide/coc.nvim', {'branch': 'release'})
  call minpac#add('osyo-manga/vim-textobj-multiblock')
  call minpac#add('previm/previm')
  call minpac#add('rbtnn/vim-vimscript_lasterror')
  call minpac#add('sgur/vim-textobj-parameter')
  call minpac#add('t9md/vim-quickhl')
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
  call minpac#add('will133/vim-dirdiff')
  call minpac#add('yuki-yano/fern-preview.vim')

  " Colorscheme
  call minpac#add('cocopon/iceberg.vim')
  call minpac#add('EdenEast/nightfox.nvim')
  call minpac#add('sainnhe/edge')

  " Vim
  call minpac#add('rhysd/vim-healthcheck', {'type': 'opt' })
  call minpac#add('mattn/vim-lexiv', {'type': 'opt'})

  " Neovim
  call minpac#add('nvim-treesitter/nvim-treesitter', {
       \ 'type': 'opt',
       \ 'do': { -> execute('silent! packadd nvim-treesitter | TSUpdate') },
       \})
  call minpac#add('nvim-treesitter/nvim-treesitter-context', {'type': 'opt'})
  call minpac#add('hrsh7th/nvim-insx', {'type': 'opt'})
  call minpac#add('rcarriga/nvim-notify', {'type': 'opt'})
endfunction

function! s:local() abort
  let proves = ['/autoload', '/plugin', '/ftplugin', '/denops']
  for path in glob('~/ghq/github.com/*/*', 1, 1, 1)
    for prove in proves
      if isdirectory(path . prove)
        execute printf('set runtimepath^=%s', fnameescape(path))
        break
      endif
    endfor
  endfor
endfunction

function! s:configure() abort
  if has('nvim')
    silent! packadd nvim-treesitter
    silent! packadd nvim-treesitter-context
    silent! packadd nvim-insx
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

call s:init()
call s:local()
call s:configure()

let s:script = expand('<sfile>')
execute printf('command! PackUpdate source %s | call s:init() | call minpac#update()', fnameescape(s:script))
execute printf('command! PackClean  source %s | call s:init() | call minpac#clean()', fnameescape(s:script))
