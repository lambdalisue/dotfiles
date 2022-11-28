if exists('g:loaded_nvim_treesitter')
  setlocal foldmethod=expr
  setlocal foldexpr=nvim_treesitter#foldexpr()
else
  setlocal foldmethod=syntax
endif

setl spell
setl autoindent
setl textwidth=0
setl colorcolumn=80
setl expandtab
setl softtabstop=2
setl shiftwidth=2
setl formatoptions&
setl formatoptions+=tqn
setl formatlistpat=^\\s*\\(\\d\\+\\\|[a-z]\\)[\\].)]\\s*

" https://habamax.github.io/2019/03/07/vim-markdown-frontmatter.html#highlight-fronmatter
silent! unlet! b:current_syntax
syntax include @Yaml syntax/yaml.vim
syntax region yamlFrontmatter start=/\%^---$/ end=/^---$/ keepend contains=@Yaml
