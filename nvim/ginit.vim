" I prefer console like GVim
"
" 'm'	Menu bar is present.
" 'e'	Add tab pages when indicated with 'showtabline'.
" 		'guitablabel' can be used to change the text in the labels.
" 		When 'e' is missing a non-GUI tab pages line may be used.
" 		The GUI tabs are only supported on some systems, currently
" 		GTK, Motif, Mac OS/X and MS-Windows.
"
" 'T'	Include Toolbar.  Currently only in Win32, GTK+, Motif, Photon
" 		and Athena GUIs.
"
" 'r'	Right-hand scrollbar is always present.
"
" 'R'	Right-hand scrollbar is present when there is a vertically
" 		split window.
"
" 'l'	Left-hand scrollbar is always present.
"
" 'L'	Left-hand scrollbar is present when there is a vertically
" 		split window.
"
" 'b'	Bottom (horizontal) scrollbar is present.  Its size depends on
" 		the longest visible line, or on the cursor line if the 'h'
" 		flag is included. |gui-horiz-scroll|
"
" 'h'	Limit horizontal scrollbar size to the length of the cursor
" 		line.  Reduces computations. |gui-horiz-scroll|
"
set guioptions&
      \ guioptions-=m
      \ guioptions-=e
      \ guioptions-=T
      \ guioptions-=r
      \ guioptions-=R
      \ guioptions-=l
      \ guioptions-=L
      \ guioptions-=b
      \ guioptions-=H

" Do not allow to access GVim menu with Alt key
set winaltkeys=no

" Visible tabline always
set showtabline=2

" disable ancient features
set noerrorbells
set visualbell t_vb=

" Disable cursor blinking in any mode
set guicursor+=a:blinkon0

" Use antialias if possible
if exists('antialias')
  set antialias
endif


if exists(':Guifont') && (has('win32') || has('win64'))
  " Font name in Windows is slitely different
  silent! Guifont! Literation\ Mono\ Powerline:h10
elseif exists(':Guifont')
  silent! Guifont! Liberation\ Mono\ for\ Powerline:h12
elseif has('gui_macvim')
  " http://d.hatena.ne.jp/yascentur/20120221/1329756132
  " http://d.hatena.ne.jp/yascentur/20110621/1308650962
  " Font size should be 2.0x
  silent! set guifont=Liberation\ Mono\ for\ Powerline:h14
else
  " Font size should be 1.5x
  silent! set guifont=Liberation\ Mono\ for\ Powerline\ 14
endif

if filereadable(expand('~/.gvimrc.local'))
  execute 'source' fnameescape(expand('~/.gvimrc.local'))
endif
