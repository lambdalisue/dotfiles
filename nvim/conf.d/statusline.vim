scriptencoding utf-8

function! s:tab(n) abort
  let hi = a:n is# tabpagenr() ? '%#TabLineSel#' : '%#TabLine#'
  let label = getcwd(0, a:n)
  let label = fnamemodify(label, ':t')
  return printf('%%%dT%s%s%%T%%#TabLineFill#', a:n, hi, label)
endfunction

function! s:safe(expr) abort
  try
    return eval(a:expr)
  catch
    return ''
  endtry
endfunction

function! s:statusline() abort
  return join([
        \ '%f%m%r%h%w',
        \ '%{exists("w:quickfix_title") ? w:quickfix_title : ""}',
        \ '%=',
        \ '%{&filetype}',
        \ '%{&fileformat}',
        \ '%{&fileencoding}',
        \])
endfunction

function! s:tabline() abort
  let lhs = [
        \ join(map(range(1, tabpagenr('$')), { -> s:tab(v:val) }), ' ┆ '),
        \]
  let rhs = [
        \ s:safe('gina#component#repo#preset("fancy")'),
        \ s:safe('gina#component#status#preset("fancy")'),
        \ s:safe('gina#component#traffic#preset("fancy")'),
        \ s:safe('wifi#component()'),
        \ s:safe('battery#component()'),
        \ '%{fnamemodify(".", ":p:~")}',
        \]
  call map(lhs, { _, v -> substitute(v, '^\s*\|\s*$', '', 'g') })
  call map(rhs, { _, v -> substitute(v, '^\s*\|\s*$', '', 'g') })
  call filter(lhs, { _, v -> !empty(v) })
  call filter(rhs, { _, v -> !empty(v) })
  return join(lhs, ' │ ') . '%=' . join(rhs, ' │ ')
endfunction

let &statusline = printf('%%!%s()', get(function('s:statusline'), 'name'))
let &tabline = printf('%%!%s()', get(function('s:tabline'), 'name'))
