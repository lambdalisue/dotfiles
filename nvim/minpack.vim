silent! packadd minpac

if !exists('*minpac#init')
  function! s:install_minpac() abort
    term git clone https://github.com/k-takata/minpac $VIMHOME/pack/minpac/opt/minpac
  endfunction
  command! Install call s:install_minpac()
  finish
endif

" Define user commands for updating/cleaning the plugins.
" Each of them loads minpac, reloads .vimrc to register the
" information of plugins, then performs the task.
command! PackUpdate packadd minpac | source $MYVIMRC | call minpac#update('', {'do': 'call minpac#status()'})
command! PackClean  packadd minpac | source $MYVIMRC | call minpac#clean()
command! PackStatus packadd minpac | source $MYVIMRC | call minpac#status()

call minpac#init()
call minpac#add('k-takata/minpac', {'type': 'opt'})

" Fundemental {{{1
call minpac#add('cocopon/iceberg.vim')
call minpac#add('ryanoasis/vim-devicons')
call minpac#add('airblade/vim-gitgutter')
call minpac#add('mattn/webapi-vim')
call minpac#add('lambdalisue/edita.vim')
call minpac#add('lambdalisue/fern.vim')
call minpac#add('lambdalisue/fern-bookmark.vim')
call minpac#add('lambdalisue/fern-comparator-lexical.vim')
call minpac#add('lambdalisue/fern-mapping-project-top.vim')
call minpac#add('lambdalisue/qfloc.vim')
call minpac#add('lambdalisue/grea.vim')
call minpac#add('lambdalisue/readablefold.vim')
call minpac#add('lambdalisue/compl-local-filename.vim')
call minpac#add('lambdalisue/suda.vim')
call minpac#add('lambdalisue/trimmer.vim')
call minpac#add('Shougo/junkfile.vim')
call minpac#add('lambdalisue/vim-marron')
call minpac#add('lambdalisue/vim-manpager')
call minpac#add('tyru/open-browser.vim')
call minpac#add('Konfekt/FastFold')
call minpac#add('kana/vim-repeat')
call minpac#add('cohama/lexima.vim')

" Dependency {{{1
call minpac#add('kana/vim-operator-user')
call minpac#add('kana/vim-textobj-user')
call minpac#add('Shougo/context_filetype.vim')
call minpac#add('tyru/current-func-info.vim')

" App {{{1
call minpac#add('cocopon/colorswatch.vim')
call minpac#add('lambdalisue/gina.vim')
call minpac#add('lambdalisue/vim-gista')
call minpac#add('mbbill/undotree')
call minpac#add('lambdalisue/lista.vim')

" Visualize {{{1
call minpac#add('lambdalisue/battery.vim')
call minpac#add('lambdalisue/wifi.vim')
call minpac#add('previm/previm')
call minpac#add('t9md/vim-quickhl')
call minpac#add('thinca/vim-zenspace')
call minpac#add('itchyny/vim-parenmatch')
call minpac#add('itchyny/vim-cursorword')

" Editing {{{1
call minpac#add('thinca/vim-template')
call minpac#add('thinca/vim-qfreplace')
call minpac#add('tyru/caw.vim')
call minpac#add('AndrewRadev/linediff.vim')
call minpac#add('lambdalisue/vim-findent')
call minpac#add('lambdalisue/vim-foldround')

" Execution {{{1
call minpac#add('thinca/vim-quickrun')
call minpac#add('lambdalisue/vim-quickrun-neovim-job')

" Completion {{{1
call minpac#add('junegunn/vim-emoji')
call minpac#add('neoclide/coc.nvim', {'branch': 'release'})
" Textobj {{{1
call minpac#add('kana/vim-textobj-line')
call minpac#add('kana/vim-textobj-indent')
call minpac#add('mattn/vim-textobj-url')
call minpac#add('sgur/vim-textobj-parameter')
call minpac#add('osyo-manga/vim-textobj-multiblock')

" Operator {{{1
call minpac#add('kana/vim-operator-replace')
call minpac#add('machakann/vim-sandwich')
call minpac#add('lambdalisue/vim-operator-breakline')

" Filetype {{{1
call minpac#add('mattn/vim-goimports')
call minpac#add('posva/vim-vue')
call minpac#add('neovimhaskell/haskell-vim')
call minpac#add('PProvost/vim-ps1')
call minpac#add('vim-scripts/python_match.vim')
call minpac#add('hynek/vim-python-pep8-indent')
call minpac#add('othree/html5.vim')
call minpac#add('cespare/vim-toml')
call minpac#add('hail2u/vim-css3-syntax')
call minpac#add('elzr/vim-json')
call minpac#add('othree/yajs.vim')
call minpac#add('othree/javascript-libraries-syntax.vim')
call minpac#add('othree/es.next.syntax.vim')
call minpac#add('leafgarland/typescript-vim')
call minpac#add('rust-lang/rust.vim')

" Vim script {{{1
call minpac#add('thinca/vim-themis')
call minpac#add('lambdalisue/vim-backslash')
call minpac#add('rbtnn/vim-vimscript_lasterror')
call minpac#add('tweekmonster/helpful.vim')
call minpac#add('thinca/vim-prettyprint')
call minpac#add('tyru/capture.vim')
call minpac#add('vim-jp/vital.vim')
call minpac#add('lambdalisue/vital-Whisky')
call minpac#add('lambdalisue/vital-Data-String-Formatter')
call minpac#add('vim-jp/vital-complete')

packloadall

" Configuration {{{1

" airblade/vim-gitgutter
let g:gitgutter_map_keys = 0
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)

" lambdalisue/grea.vim
function! s:grea(bang, query) abort
  let query = empty(a:query) ? input('Grea: ') : a:query
  if empty(query)
    redraw
    return
  endif
  execute printf('Grea%s %s .', a:bang, escape(query, ' '))
endfunction
nnoremap <silent> <Leader>gg :<C-u>call <SID>grea('', '')<CR>

" lambdalisue/suda.vim
let g:suda_smart_edit = 1
cnoreabbrev e!! e suda://%
cnoreabbrev w!! w suda://%

" lambdalisue/trimmer.vim
augroup my-trimmer
  autocmd! *
  autocmd FileType yaml,perl,python,vim,vimspec,javascript,typescript,dosbatch,ps1,sh,iss,pascal Trimmer! enable
augroup END

" Shougo/junkfile.vim
let g:junkfile#directory = expand("~/Documents/junkfiles")

" lambdalisue/vim-marron
nmap <F9> <Plug>(marron-reload-vimrc)<Plug>(marron-reload-gvimrc)

" tyru/open-browser.vim
let g:netrw_nogx = 1 " disable netrw's gx mapping
nmap gx <Plug>(openbrowser-smart-search)
xmap gx <Plug>(openbrowser-smart-search)

" lambdalisue/vim-gista
let g:gista#client#default_username = 'lambdalisue'

" mbbill/undotree
nnoremap <silent> <Leader>uu :<C-u>UndotreeToggle<CR>

" lambdalisue/lista.vim
nnoremap #  :<C-u>Lista<CR>
nnoremap g# :<C-u>ListaResume<CR>
nnoremap z# :<C-u>ListaCursorWord<CR>

" lambdalisue/battery.vim
let g:battery#update_tabline = 1

" lambdalisue/wifi.vim
let g:wifi#update_tabline = 1

" previm/previm
let g:previm_show_header = 0

" t9md/vim-quickhl
map H <Plug>(operator-quickhl-manual-this-motion)

" itchyny/vim-parenmatch
let g:loaded_matchparen = 1
let g:parenmatch = 1
function! s:toggle_vim_parenmatch() abort
  silent! call matchdelete(w:parenmatch)
  let g:parenmatch = g:parenmatch ? 0 : 1
  call parenmatch#update()
endfunction
nnoremap <silent> <Plug>(my-toggle-parenmatch)
      \ :<C-u>call <SID>toggle_vim_parenmatch()<CR>
nmap <C-g>m <Plug>(my-toggle-parenmatch)

" itchyny/vim-cursorword
let g:cursorword = 1
function! s:toggle_vim_cursorword() abort
  let g:cursorword = g:cursorword ? 0 : 1
  call cursorword#matchadd()
endfunction
nnoremap <silent> <Plug>(my-toggle-cursorword)
      \ :<C-u>call <SID>toggle_vim_cursorword()<CR>
nmap <C-g>c     <Plug>(my-toggle-cursorword)

" thinca/vim-template
function! s:template_keywords() abort
  silent! %s/<+FILE NAME+>/\=expand('%:t')/g
  silent! %s/<+DATE+>/\=strftime('%Y-%m-%d')/g
  silent! %s/<%=\(.\{-}\)%>/\=eval(submatch(1))/ge
  if search('<+CURSOR+>')
    execute 'normal! "_da>'
  endif
endfunction
augroup my-vim-template
  autocmd! *
  autocmd User plugin-template-loaded call s:template_keywords()
augroup END

" lambdalisue/vim-foldround
nmap <Leader>ff <Plug>(foldround-forward)

" junegunn/vim-emoji
set completefunc=emoji#complete

" osyo-manga/vim-textobj-multiblock
omap ab <Plug>(textobj-multiblock-a)
omap ib <Plug>(textobj-multiblock-i)
xmap ab <Plug>(textobj-multiblock-a)
xmap ib <Plug>(textobj-multiblock-i)

" kana/vim-operator-replace
map _ <Plug>(operator-replace)

" machakann/vim-sandwich
nnoremap s <Nop>
xnoremap s <Nop>

" lambdalisue/vim-operator-breakline
nmap <C-g>q <Plug>(operator-breakline-textwidth)
xmap <C-g>q <Plug>(operator-breakline-textwidth)
nmap <C-g>Q <Plug>(operator-breakline-manual)
xmap <C-g>Q <Plug>(operator-breakline-manual)

" posva/vim-vue
augroup my-vim-vue
  autocmd! *
  autocmd FileType vue syntax sync fromstart
augroup END

" othree/javascript-libraries-syntax.vim
let g:used_javascript_libs = 'jquery,underscore,vue,chai'

" rust-lang/rust.vim
let g:rust_fold = 2
let g:rust_clip_command = 'pbcopy'
let g:rustfmt_autosave = 0  " using coc-rls to auto format
let g:rustfmt_options = '--edition 2018'

" vim-jp/vital-complete
augroup my-vimtal-complete
  autocmd! *
  autocmd FileType vim,vimspec setlocal omnifunc=vital_complete#complete
augroup END

" Load plugin.d/*.vim {{{1
function! s:load_configurations() abort
  for path in glob('$VIMHOME/plugin.d/*.vim', 1, 1, 1)
    execute printf('source %s', fnameescape(path))
  endfor
endfunction
call s:load_configurations()
