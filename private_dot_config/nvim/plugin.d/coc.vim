" Use system (homebrew) node
if executable('/usr/local/bin/node')
  let g:coc_node_path = '/usr/local/bin/node'
elseif executable('/opt/homebrew/bin/node')
  let g:coc_node_path = '/opt/homebrew/bin/node'
endif

" It seems 'longest' break behavior for empty completion
" https://github.com/neoclide/coc.nvim/issues/4398
set completeopt-=longest

" Global extension names to install when they aren't installed
let g:coc_global_extensions = [
      \ '@yaegassy/coc-ruff',
      \ '@yaegassy/coc-tailwindcss3',
      \ 'coc-deno',
      \ 'coc-diagnostic',
      \ 'coc-eslint',
      \ 'coc-gauge',
      \ 'coc-git',
      \ 'coc-go',
      \ 'coc-jest',
      \ 'coc-json',
      \ 'coc-lua',
      \ 'coc-prettier',
      \ 'coc-pyright',
      \ 'coc-rust-analyzer',
      \ 'coc-sh',
      \ 'coc-sumneko-lua',
      \ 'coc-tsserver',
      \ 'coc-vetur',
      \ 'coc-vimlsp',
      \ 'coc-word',
      \ 'coc-yaml',
      \]

" Use <C-x><C-x> to trigger completion
inoremap <silent><expr> <C-x><C-x> coc#refresh()
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"

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
nmap <nowait> <C-k> <Plug>(coc-codeaction)
nmap <nowait> g<C-k> <Plug>(coc-codeaction-cursor)
vmap <nowait> <C-k> <Plug>(coc-codeaction-selected)

" Use [[ and ]]  to navigate diagnostics
nnoremap <silent> <Plug>(my-zv) <Cmd>call timer_start(10, { -> feedkeys("zv", "nx") })<CR>
nmap <nowait> [[ <Plug>(coc-diagnostic-prev)<Plug>(my-zv)
nmap <nowait> ]] <Plug>(coc-diagnostic-next)<Plug>(my-zv)
nmap <nowait><silent> qd <Cmd>call CocAction('diagnosticToggle')<CR>

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
nnoremap <silent> K <Cmd>call <SID>show_documentation()<CR>
vnoremap <silent> K <Cmd>call CocActionAsync('doHover')<CR>

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

command! CocEnableFormatOnSave call coc#config('coc.preferences.formatOnSave', v:true)
command! CocDisableFormatOnSave call coc#config('coc.preferences.formatOnSave', v:false)
