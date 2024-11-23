if has('nvim')
  augroup chameleon
    autocmd!
    autocmd User ChameleonBackgroundChanged:light ++nested silent! colorscheme dawnfox
    autocmd User ChameleonBackgroundChanged:dark ++nested silent! colorscheme nordfox
  augroup END
endif
