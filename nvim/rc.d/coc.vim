" Use system (homebrew) node
let g:coc_node_path = '/usr/local/bin/node'

" Use <C-x><C-x> to trigger completion
inoremap <silent><expr> <C-x><C-x> coc#refresh()

" Use [[ and ]]  to navigate diagnostics
nmap <silent> [[ <Plug>(coc-diagnostic-prev)
nmap <silent> ]] <Plug>(coc-diagnostic-next)

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gD <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> gQ <Plug>(coc-format-selected)
vmap <silent> gQ <Plug>(coc-format-selected)

nmap <silent> <F2> <Plug>(coc-rename)

" Use K to show documentation in preview window
nnoremap <silent> K :<C-u>call <SID>show_documentation()<CR>

function! s:show_documentation() abort
  if &filetype =~# '^\%(vim\|help\)$'
    execute 'help' expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

augroup my-coc
  autocmd! *
  " Highlight symbol under cursor on CursorHold
  autocmd CursorHold * silent call CocActionAsync('highlight')

  " Setup formatexpr specified filetype
  autocmd FileType typescript,json setlocal formatexpr=CocAction('formatSelected')

  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup END
