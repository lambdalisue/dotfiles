if exists('g:loaded_nvim_treesitter')
  setlocal foldmethod=expr
  setlocal foldexpr=nvim_treesitter#foldexpr()
else
  setlocal foldmethod=syntax
endif

" Disable vim-lexiv on ' while rust use ' as a lifetime marker
inoremap <buffer> ' '

nnoremap <buffer><silent> % <Cmd>CocCommand rust-analyzer.matchingBrace<CR>
nnoremap <buffer><silent> gK <Cmd>CocRustAnalyzerOpenDocs<CR>
nnoremap <buffer><silent> g<C-^> <Cmd>CocRustAnalyzerParentModule<CR>
nnoremap <buffer><silent> gt <Cmd>CocRustAnalyzerPeekTests<CR>
nnoremap <buffer><silent> gT <Cmd>CocRustAnalyzerTestCurrent<CR>
nnoremap <buffer><silent> <F5> <Cmd>CocRustAnalyzerReload<CR>
nnoremap <buffer><silent> <Space>rr <Cmd>CocRustAnalyzerRun<CR>


command! CocRustAnalyzerRun CocCommand rust-analyzer.run
command! CocRustAnalyzerReload CocCommand rust-analyzer.reload
command! CocRustAnalyzerPeekTests CocCommand rust-analyzer.peekTests
command! CocRustAnalyzerOpenDocs CocCommand rust-analyzer.openDocs
command! CocRustAnalyzerTestCurrent CocCommand rust-analyzer.testCurrent
command! CocRustAnalyzerParentModule CocCommand rust-analyzer.parentModule
command! CocRustAnalyzerReloadWorkspace CocCommand rust-analyzer.reloadWorkspace
command! CocRustAnalyzerViewCrateGraph CocCommand rust-analyzer.viewCrateGraph

function! s:set_rust_target(target) abort
  if a:target is# v:null
    silent! unlet g:coc_user_config['rust-analyzer.cargo.target']
  else
    silent! let g:coc_user_config['rust-analyzer.cargo.target'] = a:target
  endif
  CocRestart
endfunction

command! CocRustAnalyzerTargetPlatform call s:set_rust_target(v:null)
command! CocRustAnalyzerTargetWindows call s:set_rust_target('x86_64-pc-windows-gnu')
command! CocRustAnalyzerTargetMacOS call s:set_rust_target('x86_64-apple-darwin')
command! CocRustAnalyzerTargetLinux call s:set_rust_target('x86_64-unknown-linux-gnu')

function! s:overwrite_default_mappings() abort
  nmap <buffer><nowait> [[ <Plug>(coc-diagnostic-prev)<Plug>(my-zv)
  nmap <buffer><nowait> ]] <Plug>(coc-diagnostic-next)<Plug>(my-zv)
endfunction
silent! call s:overwrite_default_mappings()
