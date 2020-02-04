function! s:tab(n) abort
  let hi = a:n is# tabpagenr() ? '%#TabLineSel#' : '%#TabLine#'
  let bufnrs = tabpagebuflist(a:n)
  let bufnr = bufnrs[tabpagewinnr(a:n) - 1]
  let bufname = fnamemodify(bufname(bufnr), ':t')
  let bufname = empty(bufname) ? '[No name]' : bufname
  let modified = len(filter(bufnrs[:], { -> getbufvar(v:val, '&modified') })) ? '+' : ''
  return printf('%%%dT%s%s%s%%T%%#TabLineFill#', a:n, hi, bufname, modified)
endfunction

function! s:statusline() abort
  return join([
        \ '%f',
        \ '%=',
        \ '%m%r%h%w',
        \])
endfunction

function! s:tabline() abort
  return join([
        \ '%{fnamemodify(".", ":p:~")}',
        \ '|',
        \ join(map(range(1, tabpagenr('$')), { -> s:tab(v:val) })),
        \ '|',
        \ '%=',
        \ '%{gina#component#repo#preset("fancy")}',
        \ '%{gina#component#status#preset("fancy")}',
        \ '%{gina#component#traffic#preset("fancy")}',
        \ '%{wifi#component()}',
        \ '%{battery#component()}',
        \])
endfunction

let &statusline = printf('%%!%s()', get(function('s:statusline'), 'name'))
let &tabline = printf('%%!%s()', get(function('s:tabline'), 'name'))
