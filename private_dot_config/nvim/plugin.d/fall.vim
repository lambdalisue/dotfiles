function! s:init() abort
  call fall#setup(#{
        \ picker: #{
        \   items: {
        \     '': #{
        \       presenters: ["nerdfont"],
        \       params: #{
        \         border: "rounded",
        \       },
        \     },
        \   },
        \   action: #{
        \     params: #{
        \       border: "rounded",
        \     },
        \   },
        \ },
        \ presenters: #{
        \   nerdfont: #{
        \     uri: "builtin:presenters/nerdfont.ts",
        \   },
        \ },
        \})
endfunction

augroup my_fall
  autocmd!
  autocmd User DenopsPluginPost:fall call s:init()
augroup END

nnoremap <silent> <Leader>dd <Cmd>Fall file ~/.local/share/chezmoi<CR>
