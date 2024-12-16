function! s:skkeleton_init() abort
  call skkeleton#config(#{
        \ eggLikeNewline: v:true,
        \ globalDictionaries: ['/Users/alisue/Library/Containers/net.mtgto.inputmethod.macSKK/Data/Documents/Dictionaries/SKK-JISYO.L'],
        \ userDictionary: '/Users/alisue/Library/Containers/net.mtgto.inputmethod.macSKK/Data/Documents/Dictionaries/skk-jisyo.utf8',
        \})
endfunction

augroup skkeleton-initialize-pre
  autocmd!
  autocmd User skkeleton-initialize-pre call s:skkeleton_init()
augroup END

augroup skkeleton-coc
  autocmd!
  autocmd User skkeleton-enable-pre let b:coc_suggest_disable = v:true
  autocmd User skkeleton-disable-pre let b:coc_suggest_disable = v:false
augroup END

imap <C-j> <Plug>(skkeleton-enable)
cmap <C-j> <Plug>(skkeleton-enable)
tmap <C-j> <Plug>(skkeleton-enable)
