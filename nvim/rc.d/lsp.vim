let g:LanguageClient_serverCommands = {}
let g:LanguageClient_diagnosticsList = 'location'
let g:LanguageClient_diagnosticsDisplay = {
      \ 1: {
      \     'name': 'Error',
      \     'texthl': '',
      \     'signText': 'x',
      \     'signTexthl': 'Error',
      \ },
      \ 2: {
      \     'name': 'Warning',
      \     'texthl': '',
      \     'signText': '!',
      \     'signTexthl': 'Todo',
      \ },
      \ 3: {
      \     'name': 'Information',
      \     'texthl': '',
      \     'signText': 'i',
      \     'signTexthl': 'Type',
      \ },
      \ 4: {
      \     'name': 'Hint',
      \     'texthl': '',
      \     'signText': '>',
      \     'signTexthl': 'Comment',
      \ },
      \}


function! s:configure_lsp() abort
  nnoremap <buffer><silent> K :call LanguageClient_textDocument_hover()<CR>
  nnoremap <buffer><silent> gd :call LanguageClient_textDocument_definition()<CR>
  nnoremap <buffer><silent> gu :call LanguageClient_textDocument_references()<CR>
  nnoremap <buffer><silent> gs :call LanguageClient_textDocument_documentSymbol()<CR>
  nnoremap <buffer><silent> gS :call LanguageClient_workspace_symbol()<CR>
  nnoremap <buffer><silent> <F2> :call LanguageClient_textDocument_rename()<CR>
  nnoremap <buffer><silent> <F3> :call LanguageClient_textDocument_formatting()<CR>

  setlocal omnifunc=LanguageClient#complete
  setlocal formatexpr=LanguageClient_textDocument_rangeFormatting()
endfunction

function! s:configure_typescript() abort
  if exists('b:LanguageClient_serverCommand')
    return
  endif
  " Find typescript-language-server and tsc
  let ls = findfile('node_modules/.bin/typescript-language-server', '.;')
  let ls = empty(ls) ? 'typescript-language-server' : ls
  let tss = findfile('node_modules/.bin/tsserver', '.;')
  let tss = empty(tss) ? 'tsserver' : tss
  if !executable(ls)
    return
  endif
  let b:LanguageClient_serverCommand = [ls, '--stdio']
  if executable(tss)
    call extend(b:LanguageClient_serverCommand, [
          \ '--tsserver-path', fnamemodify(tss, ':p'),
          \])
  endif
  call extend(g:LanguageClient_serverCommands, {
        \ 'typescript': copy(b:LanguageClient_serverCommand),
        \})
  call s:configure_lsp()
endfunction

function! s:configure_vue() abort
  if exists('b:LanguageClient_serverCommand')
    return
  endif
  " Find typescript-language-server and tsc
  let ls = findfile('node_modules/.bin/vls', '.;')
  let ls = empty(ls) ? 'vls' : ls
  if !executable(ls)
    return
  endif
  let b:LanguageClient_serverCommand = [ls, '--stdio']
  call extend(g:LanguageClient_serverCommands, {
        \ 'vue': copy(b:LanguageClient_serverCommand),
        \})
  call s:configure_lsp()
endfunction

augroup my_lsp_configure
  autocmd! *
  autocmd FileType typescript call s:configure_typescript()
  "autocmd FileType vue call s:configure_vue()
augroup END
