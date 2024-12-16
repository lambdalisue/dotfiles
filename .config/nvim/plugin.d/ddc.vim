call ddc#custom#patch_global('ui', 'native')
call ddc#custom#patch_global('sources', ['skkeleton'])
call ddc#custom#patch_global('sourceOptions', #{
        \  skkeleton: #{
        \    mark: 'skk',
        \    matchers: [],
        \    sorters: [],
        \    converters: [],
        \    isVolatile: v:true,
        \    minAutoCompleteLength: 1,
        \  },
        \})

function s:enable_ddc() abort
  call ddc#custom#patch_global('autoCompleteEvents', [
        \ 'InsertEnter',
        \ 'TextChangedI',
        \ 'TextChangedP',
        \])
endfunction

function s:disable_ddc() abort
  call ddc#custom#patch_global('autoCompleteEvents', [])
endfunction

" initialize
call s:disable_ddc()
call ddc#enable()

augroup skkeleton
  autocmd!
  autocmd User skkeleton-enable-pre call s:enable_ddc()
  autocmd User skkeleton-disable-pre call s:disable_ddc()
augroup END
