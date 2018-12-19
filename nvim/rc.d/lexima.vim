" Clear all rules and set default rules.
call lexima#set_default_rules()

" Do not automatically input pair character when cursor is not at the eol.
" call lexima#add_rule({
"       \ 'at': '\%#\s*[^)}\]"''`]',
"       \ 'char': '(',
"       \ 'priority': 1,
"       \})
" call lexima#add_rule({
"       \ 'at': '\%#\s*[^)}\]"''`]',
"       \ 'char': '{',
"       \ 'priority': 1,
"       \})
" call lexima#add_rule({
"       \ 'at': '\%#\s*[^)}\]"''`]',
"       \ 'char': '[',
"       \ 'priority': 1,
"       \})
" call lexima#add_rule({
"       \ 'at': '\%#\s*[^)}\]"''`]',
"       \ 'char': '"',
"       \ 'priority': 1,
"       \})
" call lexima#add_rule({
"       \ 'at': '\%#\s*[^)}\]"''`]',
"       \ 'char': '''',
"       \ 'priority': 1,
"       \})
" call lexima#add_rule({
"       \ 'at': '\%#\s*[^)}\]"''`]',
"       \ 'char': '`',
"       \ 'priority': 1,
"       \})

" " Insert -> by >>
" call lexima#add_rule({
"       \ 'at': '>\%#',
"       \ 'char': '>',
"       \ 'input': '<BS>->',
"       \ 'filetype': ['cpp', 'perl']
"       \})

" " Replace =- to =~
" call lexima#add_rule({
"       \ 'at': '=\%#',
"       \ 'char': '-',
"       \ 'input': '~',
"       \})

" Vim help tag (*)
call lexima#add_rule({
      \ 'char': '*',
      \ 'input_after': '*',
      \ 'filetype': 'help',
      \})
call lexima#add_rule({
      \ 'at': '\%#\*',
      \ 'char': '*',
      \ 'leave': 1,
      \ 'filetype': 'help',
      \})
call lexima#add_rule({
      \ 'at': '\\\%#\*',
      \ 'char': '*',
      \ 'filetype': 'help',
      \})
call lexima#add_rule({
      \ 'at': '\*\%#\*',
      \ 'char': '<BS>',
      \ 'delete': 1,
      \ 'filetype': 'help',
      \})
" call lexima#add_rule({
"       \ 'at': '\%#\s*[*|^)}\]"''`]',
"       \ 'char': '*',
"       \ 'priority': 1,
"       \ 'filetype': 'help',
"       \})

" Vim help ref (|)
call lexima#add_rule({
      \ 'char': '<BAR>',
      \ 'input_after': '|',
      \ 'filetype': 'help',
      \})
call lexima#add_rule({
      \ 'at': '\%#|',
      \ 'char': '<BAR>',
      \ 'leave': 1,
      \ 'filetype': 'help',
      \})
call lexima#add_rule({
      \ 'at': '\\\%#|',
      \ 'char': '<BAR>',
      \ 'filetype': 'help',
      \})
call lexima#add_rule({
      \ 'at': '|\%#|',
      \ 'char': '<BS>',
      \ 'delete': 1,
      \ 'filetype': 'help',
      \})
" call lexima#add_rule({
"       \ 'at': '\%#\s*[*|^)}\]"''`]',
"       \ 'char': '<BAR>',
"       \ 'priority': 1,
"       \ 'filetype': 'help',
"       \})
