" Note:
"   This file will be sourced before the default FileType autocommands have
"   been installed. See |ftdetect|.
if exists('did_load_filetypes')
  finish
endif

augroup filetypedetect
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

  " mdu2
  autocmd BufNewFile,BufRead *.mdu2        setfiletype sh
  autocmd BufNewFile,BufRead *.mdu2script  setfiletype sh
  autocmd BufNewFile,BufRead skeleton.in   setfiletype fortran
  autocmd BufNewFile,BufRead mm*.in        setfiletype fortran
  autocmd BufNewFile,BufRead me*.in        setfiletype fortran
  autocmd BufNewFile,BufRead md*.in        setfiletype fortran
  autocmd BufNewFile,BufRead mdin          setfiletype fortran
  autocmd BufNewFile,BufRead mdin.*        setfiletype fortran

  " python stub file
  autocmd BufNewFile,BufRead *.pyi setfiletype python

  " Docker
  autocmd BufNewFile,BufRead Dockerfile.* setfiletype Dockerfile

  " InnoSetup
  autocmd BufNewFile,BufRead *.pp setfiletype pascal
  autocmd BufNewFile,BufRead *.isl setfiletype iss

  " Vue.js
  autocmd BufNewFile,BufRead *.vue setfiletype vue

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
