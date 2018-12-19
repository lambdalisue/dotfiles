if exists('b:current_syntax')
  finish
endif
runtime! syntax/html.vim

syntax region vueSurroundingTag contained start=+<\(script\|style\|template\)+ end=+>+ fold contains=htmlTagN,htmlString,htmlArg,htmlValue,htmlTagError,htmlEvent
syntax keyword htmlSpecialTagName contained template
syntax keyword htmlArg contained scoped ts
syntax match   htmlArg "[@v:][-:.0-9_a-z]*\>" contained
let b:current_syntax = 'vue'
