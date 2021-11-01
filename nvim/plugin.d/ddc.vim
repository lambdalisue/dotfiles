" function s:init() abort
"   call ddc#custom#patch_global('sources', ['around'])
"   call ddc#custom#patch_global('sourceOptions', {
"       \ '_': {
"       \   'ignoreCase': v:true,
"       \   'matchers': ['matcher_head'],
"       \   'sorters': ['sorter_rank'],
"       \ },
"       \ 'around': {'mark': 'A'},
"       \ })
"   call ddc#enable()
" endfunction
"
" augroup my_ddc
"   autocmd! *
"   autocmd VimEnter * call s:init()
" augroup END
"
" let g:coc_start_at_startup = 0
