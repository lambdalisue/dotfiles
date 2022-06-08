if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

setl tabstop=8
setl softtabstop=4
setl shiftwidth=4
setl smarttab
setl expandtab

setl autoindent
setl smartindent

if has('nvim')
  setlocal foldmethod=expr
  setlocal foldexpr=nvim_treesitter#foldexpr()
else
  setlocal foldmethod=syntax
endif

" Disable vim-lexiv on ' while rust use ' as a lifetime marker
inoremap <buffer> ' '

nnoremap <buffer><silent> gK <Cmd>CocCommand rust-analyzer.openDocs<CR>
nnoremap <buffer><silent> g<C-^> <Cmd>CocCommand rust-analyzer.parentModule<CR>
nnoremap <buffer><silent> <F5> <Cmd>CocCommand rust-analyzer.reloadWorkspace<CR>

command! RustReload CocCommand rust-analyzer.reload
command! RustOpenDocs CocCommand rust-analyzer.openDocs
command! RustParentModule CocCommand rust-analyzer.parentModule
command! RustReloadWorkspace CocCommand rust-analyzer.reloadWorkspace
command! RustViewCrateGraph CocCommand rust-analyzer.viewCrateGraph
