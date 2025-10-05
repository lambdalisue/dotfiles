scriptencoding utf-8

function s:tabbufname(n)
  let l:buflist = tabpagebuflist(a:n)
  let l:winnr = tabpagewinnr(a:n)
  let l:bufname = bufname(l:buflist[l:winnr - 1])
  return l:bufname ==# '' ? '[No Name]' : fnamemodify(l:bufname, ':t')
endfunction

function! s:tab(n) abort
  let l:hi = a:n is# tabpagenr() ? '%#TabLineSel#' : '%#TabLine#'
  let l:cwd = getcwd(0, a:n)
  let l:cwd = fnamemodify(l:cwd, ':t')
  let l:bufname = s:tabbufname(a:n)
  let l:label = printf('%d:%s@%s', a:n, l:bufname, l:cwd)
  return printf('%%%dT%s %s %%T%%#TabLineFil#', a:n, l:hi, l:label)
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
        \ s:safe('coc#status()'),
        \ s:safe('gin#indicator#status#get()'),
        \ '%{&filetype}',
        \ '%{&fileformat}',
        \ '%{&fileencoding}',
        \])
endfunction

function! s:tabline() abort
  let lhs = [
        \ '%{get(b:, "copilot_enabled") ? "\uf4b8 " : "\uf4b9 "}',
        \ join(map(range(1, tabpagenr('$')), { -> s:tab(v:val) }), ' '),
        \]
  let rhs = [
        \ s:safe('gin#component#worktree#name()'),
        \ s:safe('gin#component#branch#unicode()'),
        \ s:safe('gin#component#traffic#unicode()'),
        \ s:safe('wifi#component()'),
        \ s:safe('battery#component_escaped()') .. ' ',
        \ '%{fnamemodify(".", ":p:~")}',
        \]
  " call map(lhs, { _, v -> substitute(v, '^\s*\|\s*$', '', 'g') })
  " call map(rhs, { _, v -> substitute(v, '^\s*\|\s*$', '', 'g') })
  call filter(lhs, { _, v -> !empty(v) })
  call filter(rhs, { _, v -> !empty(v) })
  return join(lhs, '│') .. '%=' .. join(rhs, '│')
endfunction

let &statusline = printf('%%!%s()', get(function('s:statusline'), 'name'))
let &tabline = printf('%%!%s()', get(function('s:tabline'), 'name'))
