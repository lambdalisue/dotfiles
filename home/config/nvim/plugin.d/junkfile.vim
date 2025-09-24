let g:junkfile#directory = expand("~/Compost/junkfiles")

command! -range -nargs=? JunkfileOpen <line1>,<line2>call junkfile#open(strftime('%Y-%m-%d-%H%M%S.'), <q-args>)

