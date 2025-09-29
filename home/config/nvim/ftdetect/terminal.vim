" Neovim terminal
if has('nvim')
  autocmd TermOpen * setfiletype terminal
else
  autocmd TerminalWinOpen * setfiletype terminal
endif

tnoremap <buffer><silent> <C-PageUp> <Cmd>tabprevious<CR>
tnoremap <buffer><silent> <C-PageDown> <Cmd>tabnext<CR>
tnoremap <buffer><silent> <C-Insert> <Cmd>tabedit<CR>
tnoremap <buffer><silent> <C-Del> <Cmd>tabclose<CR>
