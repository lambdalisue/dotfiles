function! s:skkeleton_init() abort
  call skkeleton#config(#{
        \ eggLikeNewline: v:true,
        \ globalDictionaries: ['/Users/alisue/Library/Containers/net.mtgto.inputmethod.macSKK/Data/Documents/Dictionaries/SKK-JISYO.L'],
        \ userDictionary: '/Users/alisue/Library/Containers/net.mtgto.inputmethod.macSKK/Data/Documents/Dictionaries/skk-jisyo.utf8',
        \})
  call skkeleton#register_kanatable('rom', {
        \ '(' : ['（', ''],
        \ ')' : ['）', ''],
        \ 'z(' : ['【', ''],
        \ 'z)' : ['】', ''],
        \ 'z1' : ['１', ''],
        \ 'z2' : ['２', ''],
        \ 'z3' : ['３', ''],
        \ 'z4' : ['４', ''],
        \ 'z5' : ['５', ''],
        \ 'z6' : ['６', ''],
        \ 'z7' : ['７', ''],
        \ 'z8' : ['８', ''],
        \ 'z9' : ['９', ''],
        \ 'z0' : ['０', ''],
        \ 'Z1' : ['一', ''],
        \ 'Z2' : ['二', ''],
        \ 'Z3' : ['三', ''],
        \ 'Z4' : ['四', ''],
        \ 'Z5' : ['五', ''],
        \ 'Z6' : ['六', ''],
        \ 'Z7' : ['七', ''],
        \ 'Z8' : ['八', ''],
        \ 'Z9' : ['九', ''],
        \ 'Z0' : ['零', ''],
        \})
endfunction

function! s:skkeleton_enable() abort
  if exists('b:coc_suggest_disable') && !exists('b:_coc_suggest_disable_saved')
    let b:_coc_suggest_disable_saved = b:coc_suggest_disable
  endif
  if exists('b:copilot_enabled') && !exists('b:_copilot_enabled_saved')
    let b:_copilot_enabled_saved = b:copilot_enabled
  endif
  let b:coc_suggest_disable = v:true
  let b:copilot_enabled = v:false
endfunction

function! s:skkeleton_disable() abort
  if exists('b:_coc_suggest_disable_saved')
    let b:coc_suggest_disable = b:_coc_suggest_disable_saved
  else
    unlet! b:coc_suggest_disable
  endif
  if exists('b:_copilot_enabled_saved')
    let b:copilot_enabled = b:_copilot_enabled_saved
  else
    unlet! b:copilot_enabled
  endif
  unlet! b:_coc_suggest_disable_saved
  unlet! b:_copilot_enabled_saved
endfunction

augroup skkeleton-initialize-pre
  autocmd!
  autocmd User skkeleton-initialize-pre call s:skkeleton_init()
augroup END

augroup skkeleton-coc
  autocmd!
  autocmd User skkeleton-enable-pre call s:skkeleton_enable()
  autocmd User skkeleton-disable-pre call s:skkeleton_disable()
augroup END

imap <C-j> <Plug>(skkeleton-enable)
cmap <C-j> <Plug>(skkeleton-enable)
tmap <C-j> <Plug>(skkeleton-enable)
