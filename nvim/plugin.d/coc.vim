" Use system (homebrew) node
let g:coc_node_path = '/usr/local/bin/node'

" Use <C-x><C-x> to trigger completion
inoremap <silent><expr> <C-x><C-x> coc#refresh()

" Use [[ and ]]  to navigate diagnostics
nmap <silent> [[ <Plug>(coc-diagnostic-prev)
nmap <silent> ]] <Plug>(coc-diagnostic-next)

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gD <Plug>(coc-declaration)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> gR <Plug>(coc-refactor)
nmap <silent> gQ <Plug>(coc-format-selected)
vmap <silent> gQ <Plug>(coc-format-selected)

nmap <silent> <F2> <Plug>(coc-rename)

xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)

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
    call CocAction('doHover')
  endif
endfunction

augroup my-coc
  autocmd! *
  " Highlight symbol under cursor on CursorHold
  autocmd CursorHold * silent call CocActionAsync('highlight')

  " Setup formatexpr specified filetype
  autocmd FileType typescript,json,rust setlocal formatexpr=CocAction('formatSelected')

  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup END

 " Use `:Format` to format current buffer
command! -nargs=0 CocFormat call CocAction('format')

" Use `:Fold` to fold current buffer
command! -nargs=? CocFold call CocAction('fold', <f-args>)

" use `:OR` for organize import of current buffer
command! -nargs=0 CocOr call CocAction('runCommand', 'editor.action.organizeImport')
