nnoremap <silent> <Leader>ff <Cmd>Fall file<CR>
nnoremap <silent> <Leader>fd <Cmd>call fall#start(
      \ 'file',
      \ '~/ogh/lambdalisue/dotfiles',
      \ #{
      \   excludes: [
      \     '.git',
      \     '.DS_Store',
      \     'nvim/pack',
      \     'zsh/.addons',
      \   ],
      \ },
      \)<CR>
nnoremap <silent> <Leader>fo <Cmd>call fall#start(
      \ 'file',
      \ '~/Library/Mobile Documents/iCloud~md~obsidian/Documents/ObsidianVault',
      \ #{
      \   excludes: [
      \     '.DS_Store',
      \     '.obsidian',
      \   ],
      \ },
      \)<CR>
nnoremap <silent> <Leader>fl <Cmd>Fall line<CR>
nnoremap <silent> <Leader>mm <Cmd>Fall mrw<CR>
nnoremap <silent> <Leader>mu <Cmd>Fall mru<CR>
nnoremap <silent> <Leader>mr <Cmd>Fall mrr<CR>
