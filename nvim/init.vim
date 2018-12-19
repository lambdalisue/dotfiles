let s:is_windows = has('win32') || has('win64')

" Prelude {{{
if has('vim_starting')
  " Sets the character encoding inside Vim.
  set encoding=utf-8
  scriptencoding utf-8

  " Use as many color as possible
  if !has('gui_running')
        \ && exists('&termguicolors')
        \ && $COLORTERM =~# '^\%(truecolor\|24bit\)$'
    " https://medium.com/@dubistkomisch/how-to-actually-get-italics-and-true-colour-to-work-in-iterm-tmux-vim-9ebe55ebc2be
    if !has('nvim')
      let &t_8f = "\e[38;2;%lu;%lu;%lum"
      let &t_8b = "\e[48;2;%lu;%lu;%lum"
    endif
    set termguicolors       " use truecolor in term
  endif

  " Disable annoying bells
  set noerrorbells
  set novisualbell t_vb=
  if exists('&belloff')
    set belloff=all
  endif

  " Do not wait more than 100 ms for keys
  set timeout
  set ttimeout
  set ttimeoutlen=100

  " Disable unnecessary default plugins
  " let g:loaded_gzip              = 1
  " let g:loaded_tar               = 1
  " let g:loaded_tarPlugin         = 1
  " let g:loaded_zip               = 1
  " let g:loaded_zipPlugin         = 1
  let g:loaded_rrhelper          = 1
  " let g:loaded_2html_plugin      = 1
  let g:loaded_vimball           = 1
  let g:loaded_vimballPlugin     = 1
  let g:loaded_getscript         = 1
  let g:loaded_getscriptPlugin   = 1
  let g:loaded_logipat           = 1
  let g:loaded_matchparen        = 1
  let g:loaded_man               = 1
  " NOTE:
  " The Netrw is use to download a missing spellfile
  " let g:loaded_netrw             = 1
  " let g:loaded_netrwPlugin       = 1
  " let g:loaded_netrwSettings     = 1
  " let g:loaded_netrwFileHandlers = 1
endif

" }}}

" Utility {{{
if has('nvim')
  let s:mkdir = function('mkdir')
else
  function! s:mkdir(...) abort
    if isdirectory(a:1)
      return
    endif
    return call('mkdir', a:000)
  endfunction
endif

function! s:configure_path(name, pathlist) abort
  let path_separator = s:is_windows ? ';' : ':'
  let pathlist = split(expand(a:name), path_separator)
  for path in map(filter(a:pathlist, '!empty(v:val)'), 'expand(v:val)')
    if isdirectory(path) && index(pathlist, path) == -1
      call insert(pathlist, path, 0)
    endif
  endfor
  execute printf('let %s = join(pathlist, ''%s'')', a:name, path_separator)
endfunction

function! s:pick_file(pathspecs) abort
  for pathspec in filter(a:pathspecs, '!empty(v:val)')
    for path in reverse(glob(pathspec, 0, 1))
      if filereadable(path)
        return path
      endif
    endfor
  endfor
  return ''
endfunction

function! s:pick_directory(pathspecs) abort
  for pathspec in filter(a:pathspecs, '!empty(v:val)')
    for path in reverse(glob(pathspec, 0, 1))
      if isdirectory(path)
        return path
      endif
    endfor
  endfor
  return ''
endfunction

function! s:pick_executable(pathspecs) abort
  for pathspec in filter(a:pathspecs, '!empty(v:val)')
    for path in reverse(glob(pathspec, 0, 1))
      if executable(path)
        return path
      endif
    endfor
  endfor
  return ''
endfunction
" }}}

" Environment {{{
set viewdir=~/.cache/nvim/view
set undodir=~/.cache/nvim/undo
set spellfile=~/.cache/nvim/spell/spellfile.utf-8.add

" Make sure required directories exist
call s:mkdir(&viewdir, 'p')
call s:mkdir(&undodir, 'p')
call s:mkdir(fnamemodify(&spellfile, ':p:h'), 'p')

if s:is_windows
  call s:configure_path('$PATH', [
        \ 'C:\Python27',
        \ 'C:\Python26',
        \ 'C:\Python36',
        \ 'C:\Program Files\Python36',
        \])

  " Neovim
  let g:python_host_prog = s:pick_executable([
        \ 'C:\Python27\python.exe',
        \ 'C:\Python26\python.exe',
        \])
  let g:python3_host_prog = s:pick_executable([
        \ 'C:\Python36\python.exe',
        \ 'C:\Program Files\Python36\python.exe',
        \])
else
  call s:configure_path('$PATH', [
        \ '/usr/local/bin',
        \ '~/.zplug/bin',
        \ '~/.anyenv/envs/pyenv/bin',
        \ '~/.anyenv/envs/plenv/bin',
        \ '~/.anyenv/envs/rbenv/bin',
        \ '~/.anyenv/envs/ndenv/bin',
        \ '~/.anyenv/envs/pyenv/shims',
        \ '~/.anyenv/envs/plenv/shims',
        \ '~/.anyenv/envs/rbenv/shims',
        \ '~/.anyenv/envs/ndenv/shims',
        \ '~/.go/bin',
        \ '~/.cabal/bin',
        \ '~/.cache/dein/repos/github.com/thinca/vim-themis/bin',
        \ '/usr/local/texlive/2017basic/bin/x86_64-darwin',
        \])
  call s:configure_path('$MANPATH', [
        \ '/usr/local/share/man/',
        \ '/usr/share/man/',
        \ '/Applications/Xcode.app/Contents/Developer/usr/share/man',
        \ '/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/share/man',
        \])
  let $PYENV_ROOT = s:pick_directory(['~/.anyenv/envs/pyenv'])

  " Neovim
  let g:python_host_prog = s:pick_executable([
        \ '/usr/local/bin/python2',
        \ '/usr/bin/python2',
        \ '/bin/python2',
        \])
  let g:python3_host_prog = s:pick_executable([
        \ '/usr/local/bin/python3',
        \ '/usr/bin/python3',
        \ '/bin/python3',
        \])
endif
" }}}

" Language {{{

" prefer English help
set helplang=en,ja

" set default language for spell check
" cjk - ignore spell check on Asian characters (China, Japan, Korea)
set nospell
set spelllang=en_us,cjk
set fileencodings=ucs-bom,utf-8,euc-jp,iso-2022-jp,cp932,utf-16,utf-16le,cp1250

if s:is_windows
  set fileformats=dos,unix,mac
else
  set fileformats=unix,dos,mac
endif

set emoji               " use double in unicode emoji characters
set ambiwidth=single    " use single in ambiguous characters

if has('langmap') && exists('+langremap')
  " Prevent that the langmap option applies to characters that result from a
  " mapping. If set (default), this may break plugins (but it's backward
  " compatible).
  set nolangremap
endif
" }}}

" Interface {{{
set foldcolumn=0        " do not show foldcolumn
set signcolumn=yes      " always shows signcolumn
set noshowcmd           " do not display incomplete commands on the last line
set noshowmode          " do not display mode on the last line
set laststatus=2        " always shows statusline
set showtabline=2       " always shows tabline
set breakindent         " every wrapped line will continue visually indented
set report=0            " reports any changes
set previewheight=40    " specify previewwindow height
set splitright          " vertically split right

" Show a few lines of context around the cursor.  Note that this makes the
" text scroll if you mouse-click near the start or end of the window.
set scrolloff=5
" https://ddrscott.github.io/blog/2016/sidescroll/
set sidescroll=1

" Show invisible characters
set list
set listchars=tab:>-,trail:-,extends:>,precedes:<,nbsp:%,eol:$

" vertically split buffers for vimdiff
set diffopt& diffopt+=vertical

" Show bracket matches
set showmatch           " highlight a partner of cursor character (matchparen is not used)
set matchtime=1         " highlight a partner ASAP
set matchpairs&         " reset matchparis

" use rich completion system in command line
set wildmenu
set wildmode=list:longest,full
set wildoptions=tagfile
" }}}

" Behavior {{{
set autoread            " automatically read
set hidden              " hide the buffer instead of close
set switchbuf=useopen   " use an existing buffer instaed of creating a new one

set nostartofline       " let C-D, C-U,... to keep same column

set tagcase=match       " use case sensitive for tag
set smartcase           " override the ignorecase if the search pattern contains
                        " upper case characters

" Do NOT store current directory and options/mappings in view
set viewoptions&
      \ viewoptions-=curdir
      \ viewoptions-=options

" Show the effects of a command incrementally
if exists('&inccommand')
  set inccommand=nosplit
endif

if executable('rg')
  set grepprg=rg\ --vimgrep
  set grepformat=%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f\ %l%m
endif
" }}}

" Editing {{{
set smarttab        " insert blanks according to shiftwidth
set expandtab       " use spaces instead of TAB
set softtabstop=-1  " the number of spaces that a TAB counts for
set shiftwidth=4    " the number of spaces of an indent
set shiftround      " round indent to multiple of shiftwidth with > and <
set textwidth=0     " do not automatically wrap text

set autoindent      " copy indent from current line when starting a new line
set copyindent      " copy the structure of the existing lines indent when
                    " autoindenting a new line
set preserveindent  " Use :retab to clean up whitespace

set undofile        " keep undo history on undofile
set virtualedit=all " allow virtual editing in all modes

" Do not recognize octal numbers for Ctrl-A and Ctrl-X, most users find it
" confusing.
set nrformats-=octal

" t - auto-wrap text using textwidth
" c - auto-wrap comments using textwidth, inserting the
"     current comment leader automatically
" r - automatically insert the current comment leader after
"     hitting <Enter> in Insert mode
" o - automatically insert the current comment leader after
"     hitting o in Insert mode
" n - when formatting text, recognize numbered lists
" l - long lines are not broken in insert mode
" m - also break at a multi-byte character above 255.
" B - when joining lines, don't insert a space between two
"     multi-byte characters
" j - where it make sense, remove a comment leader when
"     joining lines
set formatoptions&
      \ formatoptions+=r
      \ formatoptions+=o
      \ formatoptions+=n
      \ formatoptions+=m
      \ formatoptions+=B
      \ formatoptions+=j

" use clipboard register
" - unnamed     : 'selection' in X11; clipboard in Mac OS X and Windows
" - unnamedplus : 'clipboard' in X11, Mac OS X, and Windows (but yank)
if has('win32') || has('win64') || has('mac')
  set clipboard=unnamed
else
  set clipboard=unnamed,unnamedplus
endif

" completion settings
set complete&
      \ complete+=k
      \ complete+=s
      \ complete+=i
      \ complete+=d
      \ complete+=t
set completeopt&
      \ completeopt-=preview
      \ completeopt+=menu
      \ completeopt+=longest
set showfulltag         " show both the tag name and the search pattern
set pumheight=20        " strict the item counts of completion

" K to search the help with the cursor word
set keywordprg&

" Allow backspacing over everything in insert mode.
set backspace=indent,eol,start
" }}}

" Macros {{{
augroup MyAutoCmd
  autocmd!
augroup END

function! s:cwindow() abort
  let winid = win_getid()
  cwindow
  if win_getid() != winid
    call win_gotoid(winid)
  endif
endfunction

function! s:lwindow() abort
  let winid = win_getid()
  lwindow
  if win_getid() != winid
    call win_gotoid(winid)
  endif
endfunction

autocmd MyAutoCmd QuickFixCmdPost [^l]* nested call s:cwindow()
autocmd MyAutoCmd QuickFixCmdPost l* nested call s:lwindow()

" Automatically re-assign filetype {{{
autocmd MyAutoCmd BufWritePost *
      \ if &filetype ==# '' && exists('b:ftdetect') |
      \  unlet! b:ftdetect |
      \  filetype detect |
      \ endif
"}}}

" Automatically keep cursor position {{{
" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid, when inside an event handler
" (happens when dropping a file on gvim) and for a commit message (it's
" likely a different one than last time).
autocmd MyAutoCmd BufReadPost *
      \ if line("'\"") >= 1 && line("'\"") <= line("$") && !empty(&buftype) |
      \   execute "normal! g`\"" |
      \ endif
" }}}

" Automatically restore 'view' {{{
" function! s:is_view_available() abort
"   if &buftype =~# '^\%(help\|nofile\|quickfix\|terminal\)$'
"     return 0
"   endif
"   return &buflisted && filereadable(expand('<afile>'))
" endfunction
" autocmd MyAutoCmd BufWinLeave * if s:is_view_available() | silent mkview! | endif
" autocmd MyAutoCmd BufWinEnter * if s:is_view_available() | silent! loadview | endif
" }}}

" Delete view {{{
function! s:delete_view(bang) abort
  if &modified && a:bang !=# '!'
    echohl WarningMsg
    echo 'Use bang to forcedly remove view file on modified buffer'
    echohl None
    return
  endif
  let path = substitute(expand('%:p:~'), '=', '==', 'g')
  let path = substitute(path, '/', '=+', 'g') . '='
  let path = printf('%s/%s', &viewdir, path)
  if filewritable(path)
    call delete(path)
    silent edit! %
    echo 'View file has removed: ' . path
  endif
endfunction
command! -bang Delview call s:delete_view(<q-bang>)
" }}}

" Automatically create missing directories {{{
function! s:auto_mkdir(dir, force) abort
  if empty(a:dir) || a:dir =~# '^\w\+://' || isdirectory(a:dir) || a:dir =~# '^suda:'
      return
  endif
  if !a:force
    echohl Question
    call inputsave()
    try
      let result = input(
            \ printf('"%s" does not exist. Create? [y/N]', a:dir),
            \ '',
            \)
      if empty(result)
        echohl WarningMsg
        echo 'Canceled'
        return
      endif
    finally
      call inputrestore()
      echohl None
    endtry
  endif
  call mkdir(a:dir, 'p')
endfunction
autocmd MyAutoCmd BufWritePre *
      \ call s:auto_mkdir(expand('<afile>:p:h'), v:cmdbang)
" }}}

" Automatically change working directory on vim enter {{{
function! s:workon(dir, bang) abort
  let dir = (a:dir ==# '' ? expand('%') : a:dir)
  " convert filename to directory if required
  if filereadable(dir)
    let dir = fnamemodify(expand(dir),':p:h')
  else
    let dir = fnamemodify(dir, ':p')
  endif
  " change directory to specified directory
  if isdirectory(dir)
    silent execute 'cd ' . fnameescape(dir)
    if a:bang ==# ''
      redraw | echo 'Working on: '.dir
      doautocmd <nomodeline> MyAutoCmd User my-workon-post
    endif
  endif
endfunction
autocmd MyAutoCmd VimEnter * call s:workon(expand('<afile>'), 1)
command! -nargs=? -complete=dir -bang Workon call s:workon('<args>', '<bang>')
" }}}

" Enhance performance of scroll in vsplit mode via DECSLRM {{{
" NOTE: Neovim (libvterm) already support it but Vim
" Ref: http://qiita.com/kefir_/items/c725731d33de4d8fb096
" Ref: https://github.com/neovim/libvterm/commit/04781d37ce5af3f580376dc721bd3b89c434966b
" Ref: https://twitter.com/kefir_/status/541959767002849283
if has('vim_starting') && !has('gui_running') && !has('nvim')
  " Enable origin mode and left/right margins
  function! s:enable_vsplit_mode() abort
    let &t_CS = 'y'
    let &t_ti = &t_ti . "\e[?6;69h"
    let &t_te = "\e[?6;69l\e[999H" . &t_te
    let &t_CV = "\e[%i%p1%d;%p2%ds"
    call writefile(["\e[?6;69h"], '/dev/tty', 'a')
  endfunction

  " Old vim does not ignore CPR
  map <special> <Esc>[3;9R <Nop>

  " New vim can't handle CPR with direct mapping
  " map <expr> ^[[3;3R <SID>enable_vsplit_mode()
  set t_F9=[3;3R
  map <expr> <t_F9> <SID>enable_vsplit_mode()
  let &t_RV .= "\e[?6;69h\e[1;3s\e[3;9H\e[6n\e[0;0s\e[?6;69l"
endif
" }}}
" }}}

" Mapping {{{

" define <Leader> and <LocalLeader>
noremap <Leader>      <Nop>
noremap <LocalLeader> <Nop>
let g:mapleader = "\<Space>"
let g:maplocalleader = '\'

" Disable dengerous/annoying mappings
" ZZ - save and close Vim
" ZQ - close Vim
nnoremap ZZ <Nop>
nnoremap ZQ <Nop>

" Disable middle mouse button
noremap <MiddleMouse>   <Nop>
noremap <2-MiddleMouse> <Nop>
noremap <3-MiddleMouse> <Nop>
noremap <4-MiddleMouse> <Nop>

" Emacs like movement in Insert/Command
noremap! <C-a> <Home>
noremap! <C-e> <End>
noremap! <C-f> <Right>
noremap! <C-b> <Left>
noremap! <C-d> <Del>

" Use Ctrl-f/b in Normal as well
noremap <C-f> <Right>
noremap <C-b> <Left>

" Better <C-n>/<C-p> in Command
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>
cnoremap <Up>   <C-p>
cnoremap <Down> <C-n>

" Fix unreasonable mappings by historical reason
nnoremap vv 0v$
nnoremap Y y$

" Use <Spacw>w as <C-w>
nnoremap <Space>w <C-w>
nnoremap <Space>wt :<C-u>tabnew<CR>
nnoremap <Space>wq :<C-u>tabclose<CR>

" Tab navigation
nnoremap <silent> <C-w>t :<C-u>tabnew<CR>
nnoremap <silent> <C-w><C-t> :<C-u>tabnew<CR>
nnoremap <silent> <C-w>q :<C-u>tabclose<CR>
nnoremap <silent> <C-w><C-q> :<C-u>tabclose<CR>
nnoremap <C-n> gt
nnoremap <C-p> gT

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
" Revert with ":iunmap <C-u>".
inoremap <C-u> <C-g>u<C-u>

" Jump to next/previous errors
nnoremap <silent><expr> ]c &diff ? ']c' : ":\<C-u>cnext\<CR>"
nnoremap <silent><expr> [c &diff ? ']c' : ":\<C-u>cprevious\<CR>"
nnoremap <silent> ]l :\<C-u>lnext<CR>
nnoremap <silent> [l :\<C-u>lprevious<CR>

" Toggle quickfix window with Q {{{
function! s:toggle_qf() abort
  let nwin = winnr('$')
  cclose
  if nwin == winnr('$')
    botright copen
  endif
endfunction
nnoremap <silent> <Plug>(my-toggle-quickfix)
      \ :<C-u>call <SID>toggle_qf()<CR>
nmap Q <Plug>(my-toggle-quickfix)
" }}}

" Toggle location list window with L {{{
function! s:toggle_ll() abort
  try
    let nwin = winnr('$')
    lclose
    if nwin == winnr('$')
      botright lopen
    endif
  catch /^Vim\%((\a\+)\)\=:E776/
    echohl WarningMsg
    redraw | echo 'No location list'
    echohl None
  endtry
endfunction
nnoremap <silent> <Plug>(my-toggle-locationlist)
      \ :<C-u>call <SID>toggle_ll()<CR>
nmap L <Plug>(my-toggle-locationlist)
" }}}

" Source Vim script file with <Leader>ss {{{
if !exists('*s:source_script')
  function s:source_script(path) abort
    let path = expand(a:path)
    if !filereadable(path) || getbufvar(a:path, '&filetype') !=# 'vim'
      return
    endif
    execute 'source' fnameescape(path)
    echo printf(
          \ '"%s" has sourced (%s)',
          \ simplify(fnamemodify(path, ':~:.')),
          \ strftime('%c'),
          \)
  endfunction
endif
nnoremap <F10> :<C-u>call <SID>source_script('%')<CR>
" }}}

" Zoom widnow temporary with <C-w>z {{{
function! s:toggle_window_zoom() abort
    if exists('t:zoom_winrestcmd')
        execute t:zoom_winrestcmd
        unlet t:zoom_winrestcmd
    else
        let t:zoom_winrestcmd = winrestcmd()
        resize
        vertical resize
    endif
endfunction
nnoremap <silent> <Plug>(my-zoom-window)
      \ :<C-u>call <SID>toggle_window_zoom()<CR>
nmap <C-w>z <Plug>(my-zoom-window)
nmap <C-w><C-z> <Plug>(my-zoom-window)
" }}}

" }}}

" Plugin {{{
let $MYVIM_HOME = s:is_windows
      \ ? expand('$LOCALAPPDATA/nvim')
      \ : expand('~/.config/nvim')
let s:bundle_root = expand('~/.cache/dein')
let s:bundle_dein = s:bundle_root . '/repos/github.com/Shougo/dein.vim'
if isdirectory(s:bundle_dein)
  if has('vim_starting')
    execute 'set runtimepath^=' . fnameescape(s:bundle_dein)
  endif
  if dein#load_state(s:bundle_root)
    call dein#begin(s:bundle_root, [
          \ expand('$MYVIM_HOME/init.vim'),
          \ expand('$MYVIM_HOME/rc.d/dein.toml'),
          \])
    call dein#load_toml(expand('$MYVIM_HOME/rc.d/dein.toml'))
    call dein#local(expand('~/.ghq/github.com/lambdalisue'))
    call dein#local(expand('~/.ghq/github.com/vim-jp'))
    call dein#local(expand('~/.ghq/github.com/vim-vital'))
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
" }}}

" Postludium {{{
syntax on
filetype indent plugin on

silent! colorscheme slate
silent! colorscheme iceberg

" Transparent background
function! s:transparent() abort
  highlight Normal ctermbg=NONE guibg=NONE
  highlight NonText ctermbg=NONE guibg=NONE
  highlight EndOfBuffer ctermbg=NONE guibg=NONE
  highlight Folded ctermbg=NONE guibg=NONE
  highlight LineNr ctermbg=NONE guibg=NONE
  highlight CursorLineNr ctermbg=NONE guibg=NONE
  highlight SpecialKey ctermbg=NONE guibg=NONE
  highlight ALEErrorSign ctermbg=NONE guibg=NONE
  highlight ALEWarningSign ctermbg=NONE guibg=NONE
  highlight GitGutterAdd ctermbg=NONE guibg=NONE
  highlight GitGutterChange ctermbg=NONE guibg=NONE
  highlight GitGutterChangeDelete ctermbg=NONE guibg=NONE
  highlight GitGutterDelete ctermbg=NONE guibg=NONE
endfunction
autocmd MyAutoCmd VimEnter *
      \ if !exists('g:GuiLoaded') |
      \   call s:transparent() |
      \ endif

set secure
" }}}
"-----------------------------------------------------------------------------
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
