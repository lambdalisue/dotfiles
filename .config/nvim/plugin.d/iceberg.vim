if has('nvim')
  function! s:fix_iceberg_border() abort
    highlight link FloatNormal Normal
    highlight link FloatBorder Comment
  endfunction

  augroup my_iceberg_fix
    autocmd!
    autocmd ColorScheme iceberg call s:fix_iceberg_border()
  augroup END
endif

