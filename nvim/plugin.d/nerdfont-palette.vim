let g:nerdfont_palette#source = 'nerdfont'

augroup my-nerdfont-palette
  autocmd! *
  autocmd FileType fern call nerdfont_palette#apply()
augroup END
