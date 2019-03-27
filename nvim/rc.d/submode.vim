let g:submode_keep_leaving_key = 1

call submode#enter_with('undo/redo', 'n', '', 'g-', 'g-')
call submode#enter_with('undo/redo', 'n', '', 'g+', 'g+')
call submode#map('undo/redo', 'n', '', '-', 'g-')
call submode#map('undo/redo', 'n', '', '+', 'g+')

call submode#enter_with('scroll-h', 'n', '', 'zl', 'zl')
call submode#enter_with('scroll-h', 'n', '', 'zh', 'zh')
call submode#enter_with('scroll-h', 'n', '', 'zL', 'zL')
call submode#enter_with('scroll-h', 'n', '', 'zH', 'zH')
call submode#map('scroll-h', 'n', '', 'l', 'zl')
call submode#map('scroll-h', 'n', '', 'h', 'zh')
call submode#map('scroll-h', 'n', '', 'L', 'zL')
call submode#map('scroll-h', 'n', '', 'H', 'zH')
