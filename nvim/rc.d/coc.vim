" Use system (homebrew) node
let g:coc_node_path = '/usr/local/bin/node'

" Use <C-x><C-x> to trigger completion
inoremap <silent><expr> <C-x><C-x> coc#refresh()

" Use [[ and ]]  to navigate diagnostics
nmap <silent> [[ <Plug>(coc-diagnostic-prev)
nmap <silent> ]] <Plug>(coc-diagnostic-next)

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
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

 " Use `:Format` to format current buffer
command! -nargs=0 CocFormat call CocAction('format')

" Use `:Fold` to fold current buffer
command! -nargs=? CocFold call CocAction('fold', <f-args>)

" use `:OR` for organize import of current buffer
command! -nargs=0 CocOr call CocAction('runCommand', 'editor.action.organizeImport')

" Using CocList
" Show all diagnostics
nnoremap <silent> <space>ca  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> <space>ce  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <space>cm  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <space>co  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>cs  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>cj  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>ck  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <space>cc  :<C-u>CocListResume<CR>
