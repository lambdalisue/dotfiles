let s:skk_dir = expand('~/Library/Containers/net.mtgto.inputmethod.macSKK/Data/Documents/Dictionaries')

function! s:init() abort
  call skkeleton#config(#{
        \ globalDictionaries: [s:skk_dir . '/SKK-JISYO.L'],
        \ userDictionary: s:skk_dir . '/skk-jisyo.utf8',
        \})
endfunction

augroup my-skkeleton-coc
  autocmd!
  autocmd User skkeleton-initialize-pre call s:init()
  autocmd User skkeleton-enable-pre let b:coc_suggest_disable = v:true
  autocmd User skkeleton-disable-pre let b:coc_suggest_disable = v:false
augroup END

nnoremap <C-j> echomsg "Enabled"
inoremap <C-j> <Plug>(skkeleton-enable)
cnoremap <C-j> <Plug>(skkeleton-enable)
tnoremap <C-j> <Plug>(skkeleton-enable)



