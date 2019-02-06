let g:lsp_async_completion = 1
" let g:lsp_signs_enabled = 1
" let g:lsp_diagnostics_echo_cursor = 1

function Hello()
  let count = 2
endfunction

augroup my-lsp
  autocmd! *
  if executable('typescript-language-server')
    autocmd User lsp_setup call lsp#register_server({
          \ 'name': 'typescript-language-server',
          \ 'cmd': { si -> [&shell, &shellcmdflag, 'typescript-language-server --stdio'] },
          \ 'root_uri': { si -> lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), 'tsconfig.json')) },
          \ 'whitelist': ['javascript', 'typescript'],
          \ 'priority': 5,
          \})
    autocmd FileType javascript call s:configure_lsp()
    autocmd FileType typescript call s:configure_lsp()
  endif

  if executable('pyls')
     autocmd User lsp_setup call lsp#register_server({
          \ 'name': 'pyls',
          \ 'cmd': { si -> ['pyls'] },
          \ 'whitelist': ['python'],
          \ 'workspace_config': {
          \   'pyls': {
          \     'plugins': {
          \       'jedi_definition': {
          \         'follow_imports': v:true,
          \         'follow_builtin_imports': v:true,
          \       },
          \     },
          \   },
          \ },
          \ 'priority': 5,
          \})
    autocmd FileType python call s:configure_lsp()
  endif

  if executable('golsp')
     autocmd User lsp_setup call lsp#register_server({
          \ 'name': 'golsp',
          \ 'cmd': { si -> ['golsp', '-mode', 'stdio'] },
          \ 'whitelist': ['go'],
          \ 'priority': 5,
          \})
    autocmd FileType go call s:configure_lsp()
  elseif executable('bingo')
     autocmd User lsp_setup call lsp#register_server({
          \ 'name': 'bingo',
          \ 'cmd': { si -> ['bingo', '-mode', 'stdio'] },
          \ 'whitelist': ['go'],
          \ 'priority': 5,
          \})
    autocmd FileType go call s:configure_lsp()
  endif

  if executable('efm-langserver')
    if executable('vint')
      autocmd User lsp_setup call lsp#register_server({
            \ 'name': 'efm-langserver-vint',
            \ 'cmd': { si -> ['efm-langserver', '-stdin', &shell, &shellcmdflag, 'vint -'] },
            \ 'whitelist': ['vim'],
            \})
      autocmd FileType vim call s:configure_lsp()
    endif
  endif
augroup END

function! s:configure_lsp() abort
  nnoremap <buffer> gd :<C-u>LspDefinition<CR>
  nnoremap <buffer> gD :<C-u>LspReferences<CR>
  nnoremap <buffer> gs :<C-u>LspDocumentSymbol<CR>
  nnoremap <buffer> gS :<C-u>LspWorkspaceSymbol<CR>
  nnoremap <buffer> gQ :<C-u>LspDocumentFormat<CR>
  vnoremap <buffer> gQ :LspDocumentRangeFormat<CR>
  nnoremap <buffer> K :<C-u>LspHover<CR>
  nnoremap <buffer> <F1> :<C-u>LspImplementation<CR>
  nnoremap <buffer> <F2> :<C-u>LspRename<CR>
  setlocal omnifunc=lsp#complete
endfunction
