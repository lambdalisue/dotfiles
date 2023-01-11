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

" Environment {{{
if has('nvim')
  set undodir=~/.cache/nvim/undo
  set viewdir=~/.cache/nvim/view
  set spellfile=~/.cache/nvim/spell/spellfile.utf-8.add
else
  set undodir=~/.cache/vim/undo
endif

" Make sure required directories exist
call mkdir(&viewdir, 'p')
call mkdir(&undodir, 'p')
call mkdir(fnamemodify(&spellfile, ':p:h'), 'p')

" Use PowerShell on Windows
if s:is_windows
  " :help shell-powershell
  let &shell = executable('pwsh') ? 'pwsh' : 'powershell'
  let &shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;'
  let &shellredir = '-RedirectStandardOutput %s -NoNewWindow -Wait'
  let &shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
  set shellquote= shellxquote=
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

if has('nvim')
  silent! set laststatus=3
else
  silent! set laststatus=1
endif
silent! set cmdheight=0

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
set noswapfile
set smarttab        " insert blanks according to shiftwidth
set expandtab       " use spaces instead of TAB
set softtabstop=-1  " the number of spaces that a TAB counts for
set shiftwidth=2    " the number of spaces of an indent
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

" Functions {{{
function! SafePumVisible() abort
  try
    return coc#pum#visible()
  catch
    return pumvisible()
  endtry
endfunction

function! s:revise_colorscheme() abort
  if system('defaults read -g AppleInterfaceStyle') ==# "Dark\n"
    silent! colorscheme nordfox
  else
    silent! colorscheme dawnfox
  endif
endfunction
command! ReviseColorscheme call s:revise_colorscheme()
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
" }}}

" Postludium {{{

" Plugin
source $VIMHOME/minpac.vim

syntax on
filetype indent plugin on

" Load conf.d/*.vim
function! s:load_configurations() abort
  for path in glob('$VIMHOME/conf.d/*.vim', 1, 1, 1)
    execute printf('source %s', fnameescape(path))
  endfor
endfunction
call s:load_configurations()

" silent! colorscheme slate
silent! colorscheme iceberg
silent! colorscheme edge
set background=dark

if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif

set secure
" }}}
"-----------------------------------------------------------------------------
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
