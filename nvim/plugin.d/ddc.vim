" Customize global settings
" Use around source.
call ddc#custom#patch_global('sources', ['around'])
" Enable default matcher/sorter.
call ddc#custom#patch_global('sourceOptions', {
     \ '_': {
     \   'matchers': ['matcher_head'],
     \   'sorters': ['sorter_rank']},
     \ })
" Change source options
call ddc#custom#patch_global('sourceOptions', {
     \ 'around': {'matchers': ['matcher_head'], 'mark': 'A'},
     \ })
call ddc#custom#patch_global('sourceParams', {
     \ 'around': {'maxSize': 500},
     \ })

" Customize settings on a filetype
call ddc#custom#patch_filetype(['c', 'cpp'], 'sources', ['around', 'clangd'])
call ddc#custom#patch_filetype(['c', 'cpp'], 'sourceOptions', {
     \ 'clangd': {'mark': 'C'},
     \ })
call ddc#custom#patch_filetype('markdown', 'sourceParams', {
     \ 'around': {'maxSize': 100},
     \ })

" " Disable CoC
" let g:coc_start_at_startup = 0
" " Use ddc.
" call ddc#enable()
