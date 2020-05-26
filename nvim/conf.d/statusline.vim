scriptencoding utf-8

function! s:tab(n) abort
  let hi = a:n is# tabpagenr() ? '%#TabLineSel#' : '%#TabLine#'
  let bufnrs = tabpagebuflist(a:n)
  let bufnr = bufnrs[tabpagewinnr(a:n) - 1]
  let bufname = fnamemodify(bufname(bufnr), ':t')
  let bufname = empty(bufname) ? '[No name]' : bufname
  let modified = len(filter(bufnrs[:], { -> getbufvar(v:val, '&modified') })) ? '+' : ''
  return printf('%%%dT%s%s%s%%T%%#TabLineFill#', a:n, hi, bufname, modified)
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
        \ '%f',
        \ '%{exists("w:quickfix_title") ? w:quickfix_title : ""}',
        \ '%=',
        \ '%m%r%h%w',
        \])
endfunction

function! s:tabline() abort
  let lhs = [
        \ '%{fnamemodify(".", ":p:~")}',
        \ join(map(range(1, tabpagenr('$')), { -> s:tab(v:val) }), ' ┆ '),
        \]
  let rhs = [
        \ s:safe('gina#component#repo#preset("fancy")'),
        \ s:safe('gina#component#status#preset("fancy")'),
        \ s:safe('gina#component#traffic#preset("fancy")'),
        \ s:safe('wifi#component()'),
        \ s:safe('battery#component()'),
        \]
  call map(lhs, { _, v -> substitute(v, '^\s*\|\s*$', '', 'g') })
  call map(rhs, { _, v -> substitute(v, '^\s*\|\s*$', '', 'g') })
  call filter(lhs, { _, v -> !empty(v) })
  call filter(rhs, { _, v -> !empty(v) })
  return join(lhs, ' │ ') . '%=' . join(rhs, ' │ ')
endfunction

let &statusline = printf('%%!%s()', get(function('s:statusline'), 'name'))
let &tabline = printf('%%!%s()', get(function('s:tabline'), 'name'))
