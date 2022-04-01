let $VIMHOME = expand('<sfile>:p:h')
let s:is_windows = has('win32')

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

    if exists('&pumblend')
      set pumblend=20
    endif
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
  let g:loaded_gzip              = 1
  let g:loaded_tar               = 1
  let g:loaded_tarPlugin         = 1
  let g:loaded_zip               = 1
  let g:loaded_zipPlugin         = 1
  let g:loaded_rrhelper          = 1
  let g:loaded_2html_plugin      = 1
  let g:loaded_vimball           = 1
  let g:loaded_vimballPlugin     = 1
  let g:loaded_getscript         = 1
  let g:loaded_getscriptPlugin   = 1
  let g:loaded_logipat           = 1
  let g:loaded_matchparen        = 1
  let g:loaded_man               = 1
  " NOTE:
  " The Netrw is use to download a missing spellfile
  let g:loaded_netrw             = 1
  let g:loaded_netrwPlugin       = 1
  let g:loaded_netrwSettings     = 1
  let g:loaded_netrwFileHandlers = 1
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
set spellfile=~/.cache/nvim/spell/spellfile.utf-8.add
set viewdir=~/.cache/nvim/view
if has('nvim')
  " NOTE: Neovim change undo file format
  set undodir=~/.cache/nvim/undo
else
  set undodir=~/.cache/vim/undo
endif

" Make sure required directories exist
call s:mkdir(&viewdir, 'p')
call s:mkdir(&undodir, 'p')
call s:mkdir(fnamemodify(&spellfile, ':p:h'), 'p')

if !s:is_windows && has('nvim')
  let g:loaded_python_provider = 0
  let g:python3_host_prog = s:pick_executable([
       \ '/opt/homebrew/bin/python3',
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
set mouse=nvr
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
set nolist
set listchars=tab:>-,trail:-,extends:>,precedes:<,nbsp:%,eol:$

set fillchars=diff:/

" vertically split buffers for vimdiff
if has('vim-8.0.1361') || has('nvim')
  set diffopt&
        \ diffopt+=vertical
        \ diffopt+=hiddenoff
endif

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

set grepformat=%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f\ %l%m
if executable('rg')
  set grepprg=rg\ --vimgrep
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
      \ completeopt+=preview
      \ completeopt+=menu
      \ completeopt+=longest
set showfulltag         " show both the tag name and the search pattern
set pumheight=20        " strict the item counts of completion

" K to search the help with the cursor word
set keywordprg&

" Allow backspacing over everything in insert mode.
set backspace=indent,eol,start

" Do NOT restart search on bottom
set nowrapscan
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

" Register {{{
function! s:clear_register() abort
  let rs = split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-"', '\zs')
  for r in rs
    call setreg(r, [])
  endfor
endfunction
command! ClearRegister call s:clear_register()
" }}}

" Grep {{{
command! -nargs=+ Grep execute 'silent grep! <args>' | copen
" }}}

" Qbuffers
command! Qbuffers call setqflist(map(filter(range(1, bufnr('$')), 'buflisted(v:val)'), '{"bufnr":v:val}'))

" Qinvoke/Linvoke {{{
function! s:invoke(cmd, callback) abort
  let Process = vital#vital#import('Async.Promise.Process')
  let temp = tempname()
  let args = [
        \ &shell,
        \ &shellcmdflag,
        \ join([a:cmd, &shellpipe, temp]),
        \]
  call Process.start(args)
        \.then({ r -> a:callback(temp) })
        \.catch({ e -> execute('echomsg string(e)', '') })
endfunction
command! -nargs=* Qinvoke call s:invoke(<q-args>, { v -> execute('cfile ' . fnameescape(v), '') })
command! -nargs=* Linvoke call s:invoke(<q-args>, { v -> execute('lfile ' . fnameescape(v), '') })
" }}}

" GetChar {{{
function! s:getchar() abort
  redraw | echo 'Press any key: '
  let c = getchar()
  while c ==# "\<CursorHold>"
    redraw | echo 'Press any key: '
    let c = getchar()
  endwhile
  redraw | echo printf('Raw: "%s" | Char: "%s"', c, nr2char(c))
endfunction
command! GetChar call s:getchar()
" }}}

" Timeit {{{
function! s:timeit(command) abort
  let start = reltime()
  execute a:command
  let delta = reltime(start)
  echomsg '[timeit]' a:command
  echomsg '[timeit]' reltimestr(delta)
endfunction
command! -nargs=* Timeit call s:timeit(<q-args>)
" }}}

" }}}

" Mapping {{{

" define <Leader> and <LocalLeader>
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

" Swap ; and : in normal/visual mode
nnoremap ; :
xnoremap ; :
nnoremap : ;
xnoremap : ;

" Prefer gF
nnoremap gf gFzv
nnoremap gF gfzv
nnoremap <C-w>f <C-w>Fzv
nnoremap <C-w><C-f> <C-w>Fzv
nnoremap <C-w>F <C-w>fzv

" Do NOT yank with x/s
nnoremap x "_x
nnoremap s "_s

" Do NOT rewrite register after paste
" http://baqamore.hatenablog.com/entry/2016/07/07/201856
xnoremap <expr> p printf('pgv"%sygv<esc>', v:register)

" Use Ctrl-f/b in Normal as well
noremap <C-f> <Right>
noremap <C-b> <Left>

" Better <C-n>/<C-p> in Command
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>
cnoremap <Up>   <C-p>
cnoremap <Down> <C-n>

" Fix unreasonable mappings by historical reason
nnoremap Y y$

function! s:yank_without_indent() abort
  normal! gvy
  let content = split(@@, '\n')
  let leading = min(map(copy(content), { _, v -> len(matchstr(v, '^\s*')) }))
  call map(content, { _, v -> v[leading:] })
  let @@ = join(content, "\n")
endfunction
vnoremap gy <Esc>:<C-u>call <SID>yank_without_indent()<CR>

" Tab navigation
nnoremap <silent> <C-w>t :<C-u>tabnew<CR>
nnoremap <silent> <C-w><C-t> :<C-u>tabnew<CR>
nnoremap <silent> <C-w>q :<C-u>tabclose<CR>
nnoremap <silent> <C-w><C-q> :<C-u>tabclose<CR>
nnoremap <C-n> gt
nnoremap <C-p> gT

" Open terminal
nnoremap <Leader>tt :<C-u>tabnew<CR><BAR>:terminal<CR>

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
" Revert with ":iunmap <C-u>".
inoremap <C-u> <C-g>u<C-u>

" CTRL-L to fix syntax highlight
nnoremap <silent><expr> <C-l> empty(get(b:, 'current_syntax'))
      \ ? "\<C-l>"
      \ : "\<C-l>:syntax sync fromstart\<CR>"

" Insert UUID by <F2>
function! s:uuid() abort
  let r = system('uuidgen')
  let r = substitute(r, '^[\r\n\s]*\|[\r\n\s]*$', '', 'g')
  return r
endfunction
inoremap <silent> <Plug>(my-insert-uuid) <C-r>=<SID>uuid()<CR>
imap <F2> <Plug>(my-insert-uuid)

" Yank Base64 encoded/decoded text of the selected text
function! s:encode_base64() abort
  normal! gvy
  let @@ = system('base64', @@)
  let @@ = substitute(@@, '^[\r\n\s]*\|[\r\n\s]*$', '', 'g')
  normal! gvp
endfunction
function! s:decode_base64() abort
  normal! gvy
  let @@ = system('base64 -d', @@)
  let @@ = substitute(@@, '^[\r\n\s]*\|[\r\n\s]*$', '', 'g')
  normal! gvp
endfunction
vnoremap <silent> <Plug>(my-decode-base64) :call <SID>encode_base64()<CR>
vnoremap <silent> <Plug>(my-encode-base64) :call <SID>decode_base64()<CR>
vmap <F3> <Plug>(my-decode-base64)
vmap <F4> <Plug>(my-encode-base64)

" Focus floating window with <C-w><C-w> {{{
if has('nvim')
  function! s:focus_floating() abort
    if !empty(nvim_win_get_config(win_getid()).relative)
      wincmd p
      return
    endif
    for winnr in range(1, winnr('$'))
      let winid = win_getid(winnr)
      let conf = nvim_win_get_config(winid)
      if conf.focusable && !empty(conf.relative)
        call win_gotoid(winid)
        return
      endif
    endfor
  endfunction
  nnoremap <silent> <C-w><C-w> :<C-u>call <SID>focus_floating()<CR>
endif
" }}}

" Grep with <Leader>gg {{{
function! s:grep(bang, query) abort
  let query = empty(a:query) ? input('grep: ') : a:query
  if empty(query)
    redraw
    return
  endif
  execute printf('silent grep%s %s .', a:bang, escape(query, ' '))
endfunction
nnoremap <silent> <Leader>gg :<C-u>call <SID>grep('', '')<CR>
command! -nargs=* -bang Grep call s:grep(<q-bang>, <q-args>)

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

" Postludium {{{

" Plugin
source $VIMHOME/jetpack.vim

syntax on
filetype indent plugin on

" Load conf.d/*.vim
function! s:load_configurations() abort
  for path in glob('$VIMHOME/conf.d/*.vim', 1, 1, 1)
    execute printf('source %s', fnameescape(path))
  endfor
endfunction
call s:load_configurations()

function! s:highlight() abort
  highlight CursorLine guibg=#444444
  highlight VertSplit ctermfg=1 guifg=#aaaaaa
  highlight Tabline ctermfg=1 guifg=#aaaaaa
  highlight TablineSel ctermfg=1 guifg=#aaaaaa
  highlight TablineFill ctermfg=1 guifg=#aaaaaa
endfunction
augroup my
  autocmd! *
  autocmd ColorScheme * call s:highlight()
augroup END

silent! colorscheme slate
silent! colorscheme iceberg

if has('nvim')
  set laststatus=3        " always shows statusline
endif

set secure
" }}}
"-----------------------------------------------------------------------------
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
