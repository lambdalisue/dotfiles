setlocal nolist
setlocal nospell

" Close with q
nnoremap <buffer><expr> q &modifiable ? 'q' : ':<C-u>close<CR>'

