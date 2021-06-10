" Note:
"   This file will be sourced before the default FileType autocommands have
"   been installed. See |ftdetect|.
if exists('did_load_filetypes')
  finish
endif

augroup filetypedetect
  autocmd BufNewFile,BufRead .env       setfiletype sh
  autocmd BufNewFile,BufRead .envrc     setfiletype sh

  autocmd BufNewFile,BufRead *.txt      setfiletype markdown
  autocmd BufNewFile,BufRead *.md       setfiletype markdown
  autocmd BufNewFile,BufRead *.mkd      setfiletype markdown
  autocmd BufNewFile,BufRead *.markdown setfiletype markdown

  autocmd BufNewFile,BufRead *.t        setfiletype perl
  autocmd BufNewFile,BufRead *.psgi     setfiletype perl
  autocmd BufNewFile,BufRead *.tt       setfiletype tt2html

  autocmd BufNewFile,BufRead *.pml      setfiletype pymol
  autocmd BufNewFile,BufRead SConstruct setfiletype python

  autocmd BufNewFile,BufRead *.less     setfiletype less
  autocmd BufNewFile,BufRead *.sass     setfiletype sass
  autocmd BufNewFile,BufRead *.scss     setfiletype scss
  autocmd BufNewFile,BufRead *.ts       setfiletype typescript
  autocmd BufNewFile,BufRead *.json     setfiletype json
  autocmd BufNewFile,BufRead .babelrc   setfiletype json
  autocmd BufNewFile,BufRead *.jsm      setfiletype javascript
  autocmd BufNewFile,BufRead *.coffee   setfiletype coffeescript
  autocmd BufNewFile,BufRead Cakefile   setfiletype coffeescript

  autocmd BufNewFile,BufRead *.tex      setfiletype tex
  autocmd BufNewFile,BufRead *.toml     setfiletype toml

  " Apple Script
  autocmd BufNewFile,BufRead *.scpt        setfiletype applescript
  autocmd BufNewFile,BufRead *.applescript setfiletype applescript

  " python stub file
  autocmd BufNewFile,BufRead *.pyi setfiletype python

  " Docker
  function! s:filetype_dockerfile() abort
    if expand('%:p:g?\\?/?') =~# 'dockerfiles/[^/]\+$' && getline(1) =~# '^FROM '
      setfiletype Dockerfile
    endif
  endfunction
  autocmd BufNewFile,BufRead Dockerfile.* setfiletype Dockerfile
  autocmd BufWinEnter *
        \ if &filetype ==# 'conf' || &filetype ==# '' |
        \   call s:filetype_dockerfile() |
        \ endif

  " InnoSetup
  autocmd BufNewFile,BufRead *.pp setfiletype pascal
  autocmd BufNewFile,BufRead *.isl setfiletype iss

  " Neovim terminal
  if has('nvim')
    autocmd TermOpen * setfiletype terminal
  else
    autocmd BufWinEnter *
          \ if &filetype ==# '' && &buftype ==# 'terminal' |
          \   setfiletype terminal |
          \ endif
  endif
augroup END
