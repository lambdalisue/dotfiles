" Use system (homebrew) node
let g:coc_node_path = '/usr/local/bin/node'

set updatetime=300

" Use <C-x><C-x> to trigger completion
inoremap <silent><expr> <C-x><C-x> coc#refresh()

" Use [[ and ]]  to navigate diagnostics
nmap <silent> [[ <Plug>(coc-diagnostic-prev)zv
nmap <silent> ]] <Plug>(coc-diagnostic-next)zv

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gD <Plug>(coc-declaration)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> gR <Plug>(coc-refactor)
nmap <silent> gq <Plug>(coc-format)
nmap <silent> gQ <Plug>(coc-format-selected)
vmap <silent> gQ <Plug>(coc-format-selected)
nmap <silent> <F2> <Plug>(coc-rename)

xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ic <Plug>(coc-classobj-i)
omap ac <Plug>(coc-classobj-a)

" coc-snippets
imap <C-l> <Plug>(coc-snippets-expand)
vmap <C-j> <Plug>(coc-snippets-select)
imap <C-j> <Plug>(coc-snippets-expand-jump)
let g:coc_snippet_next = '<C-j>'
let g:coc_snippet_prev = '<C-k>'

" Use K to show documentation in preview window
nnoremap <silent> K :<C-u>call <SID>show_documentation()<CR>

function! s:show_documentation() abort
  if &filetype =~# '^\%(vim\|help\)$'
    try
      execute 'help' expand('<cword>')
    catch
      echohl Error
      echo v:exception
      echohl None
    endtry
  else
    call CocActionAsync('doHover')
  endif
endfunction

augroup my-coc
  autocmd! *

  " Highlight symbol under cursor on CursorHold
  autocmd CursorHold * silent call CocActionAsync('highlight')

  " Format prior to save
  autocmd BufWritePre * silent call CocAction('format')

  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup END

command! CocSnippet CocCommand snippets.editSnippets
