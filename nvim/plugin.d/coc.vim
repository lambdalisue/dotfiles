" let g:coc_start_at_startup = 0

" Use system (homebrew) node
let g:coc_node_path = '/usr/local/bin/node'

" Global extension names to install when they aren't installed
let g:coc_global_extensions = [
      \ 'coc-deno',
      \ 'coc-eslint',
      \ 'coc-git',
      \ 'coc-go',
      \ 'coc-jest',
      \ 'coc-json',
      \ 'coc-prettier',
      \ 'coc-pyright',
      \ 'coc-rust-analyzer',
      \ 'coc-sh',
      \ 'coc-tsserver',
      \ 'coc-vimlsp',
      \ 'coc-word',
      \ 'coc-yaml',
      \]
      "\ '@yaegassy/coc-nginx',
      "\ 'coc-diagnostic',
      "\ 'coc-snippets',
      "\ 'coc-solargraph',
      "\ 'coc-tailwindcss',

set updatetime=300

" Use <C-x><C-x> to trigger completion
inoremap <silent><expr> <C-x><C-x> coc#refresh()

" Use [[ and ]]  to navigate diagnostics
nnoremap <silent> <Plug>(my-zv) :<C-u>call timer_start(10, { -> feedkeys("zv", "nx") })<CR>
nmap <nowait> [[ <Plug>(coc-diagnostic-prev)<Plug>(my-zv)
nmap <nowait> ]] <Plug>(coc-diagnostic-next)<Plug>(my-zv)

nmap <nowait> gd <Plug>(coc-definition)
nmap <nowait> gD <Plug>(coc-declaration)
nmap <nowait> gi <Plug>(coc-implementation)
nmap <nowait> gy <Plug>(coc-type-definition)
nmap <nowait> gr <Plug>(coc-references)
nmap <nowait> gR <Plug>(coc-refactor)
nmap <nowait> gq <Plug>(coc-format)
nmap <nowait> gQ <Plug>(coc-format-selected)
vmap <nowait> gQ <Plug>(coc-format-selected)
nmap <nowait> qf <Plug>(coc-fix-current)
nmap <nowait> qr <Plug>(coc-rename)
nmap <silent><nowait> <C-k> <Plug>(coc-codeaction-line)
vmap <silent><nowait> <C-k> <Plug>(coc-codeaction-selected)

xmap <nowait> if <Plug>(coc-funcobj-i)
xmap <nowait> af <Plug>(coc-funcobj-a)
omap <nowait> if <Plug>(coc-funcobj-i)
omap <nowait> af <Plug>(coc-funcobj-a)
xmap <nowait> ic <Plug>(coc-classobj-i)
xmap <nowait> ac <Plug>(coc-classobj-a)
omap <nowait> ic <Plug>(coc-classobj-i)
omap <nowait> ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
" Note coc#float#scroll works on neovim >= 0.4.3 or vim >= 8.2.0750
if has('nvim-0.4.3') || has('patch-8.2.0750')
  nnoremap <nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
endif
" NeoVim-only mapping for visual mode scroll
" Useful on signatureHelp after jump placeholder of snippet expansion
if has('nvim')
  vnoremap <nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#nvim_scroll(1, 1) : "\<C-f>"
  vnoremap <nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#nvim_scroll(0, 1) : "\<C-b>"
endif

" Use K to show documentation in preview window
function! s:show_documentation() abort
  if (index(['vim','help'], &filetype) >= 0)
    execute 'help' expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute printf('!%s', &keywordprg) expand('<cword>')
  endif
endfunction
nnoremap <silent> K :<C-u>call <SID>show_documentation()<CR>

augroup my-coc
  autocmd!
  " Highlight symbol under cursor on CursorHold
  autocmd CursorHold * silent! call CocActionAsync('highlight')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup END

" coc-git
nmap <silent> gs <Plug>(coc-git-chunkinfo)
nmap <silent> gp <Plug>(coc-git-prevchunk)
nmap <silent> gn <Plug>(coc-git-nextchunk)

" coc-snippets
let g:coc_snippet_next = '<C-j>'
let g:coc_snippet_prev = '<C-k>'
imap <C-l> <Plug>(coc-snippets-expand)
vmap <C-j> <Plug>(coc-snippets-select)
imap <C-j> <Plug>(coc-snippets-expand-jump)
xmap <C-s> <Plug>(coc-convert-snippet)
command! CocSnippet CocCommand snippets.editSnippets


function! s:switch_coc_deno() abort
  if exists('g:coc_deno')
    return
  endif
  let path = empty(expand('%')) ? '.' : '%:p:h'
  if empty(finddir("node_modules", path . ';'))
    call coc#config('deno.enable', v:true)
    call coc#config('tsserver.enable', v:false)
    call coc#config('prettier.onlyUseLocalVersion', v:true)
  else
    call coc#config('deno.enable', v:false)
    call coc#config('tsserver.enable', v:true)
  endif
endfunction
augroup my-coc-deno
  autocmd BufRead,BufNewFile *.ts ++once call s:switch_coc_deno()
augroup END
