" Disable vim-lexiv on ' while rust use ' as a lifetime marker
inoremap <buffer> ' '

nnoremap <buffer><silent> gK <Cmd>CocCommand rust-analyzer.openDocs<CR>
nnoremap <buffer><silent> <F5> <Cmd>CocCommand rust-analyzer.reloadWorkspace<CR>
