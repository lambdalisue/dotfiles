function! s:regulate_glyph_palette() abort
  highlight! link GlyphPalette7 Comment
endfunction

augroup my-glyph-palette
  autocmd! *
  autocmd FileType fern call glyph_palette#apply()
  autocmd ColorScheme * call s:regulate_glyph_palette()
augroup END
