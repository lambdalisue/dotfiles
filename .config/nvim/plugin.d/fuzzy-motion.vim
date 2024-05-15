nnoremap <Leader>jj <Cmd>FuzzyMotion<CR>

" Enable kensaku.vim matcher
let g:fuzzy_motion_matchers = ['fzf', 'kensaku']

" Disable word split feature
let g:fuzzy_motion_word_filter_regexp_list = []
