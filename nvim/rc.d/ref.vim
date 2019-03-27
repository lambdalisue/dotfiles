let g:ref_source_webdict_sites = {
      \ 'stackage': {
      \   'url': 'https://stackage.org/lts-12.26/hoogle?q=%s',
      \ }
      \}

command! -nargs=+ Hoogle Ref webdict stackage <args>
