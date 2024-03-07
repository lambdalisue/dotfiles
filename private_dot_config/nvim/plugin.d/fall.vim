function! s:init() abort
  call fall#setup(#{
       \ picker: #{
       \   source: {
       \     '': #{
       \       params: #{
       \         border: 'rounded',
       \       },
       \     },
       \   },
       \   action: #{
       \     params: #{
       \       border: 'rounded',
       \     },
       \   },
       \ },
       \})
endfunction

augroup my_fall
  autocmd!
  autocmd User DenopsPluginPost:fall call s:init()
augroup END

nnoremap <silent> <Leader>ff <Cmd>Fall file<CR>
nnoremap <silent> <Leader>fd <Cmd>Fall file ~/.local/share/chezmoi<CR>
nnoremap <silent> <Leader>fl <Cmd>Fall line<CR>
