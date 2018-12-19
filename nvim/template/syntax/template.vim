if exists('b:current_syntax')
  finish
endif
let b:current_syntax = 'XXXXX'
let s:save_cpoptions = &cpoptions
set cpoptions&vim

syntax clear
<+CURSOR+>

let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
