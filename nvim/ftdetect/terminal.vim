" Neovim terminal
if has('nvim')
  autocmd TermOpen * setfiletype terminal
else
  autocmd TerminalWinOpen * setfiletype terminal
endif
