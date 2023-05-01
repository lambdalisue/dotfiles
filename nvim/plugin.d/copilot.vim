" Disable Copilot for all in default
let g:copilot_filetypes = {
      \ '*': v:false,
      \}

function! s:is_copilot_acceptable(path) abort
  if a:path !~# '^\~/ghq/'
    " Do NOT allow copilot not under git repository for security reason.
    return 0
  elseif a:path =~# '^\~/ghq/github\.com/fixpoint/'
    " Do NOT allow copilot under fixpoint organization for security reason.
    return 0
  endif
  return 1
endfunction

function! s:enable_copilot() abort
  let path = fnamemodify(expand('%'), ':p:~')
  if &buftype ==# '' && s:is_copilot_acceptable(path)
    echomsg printf('Copilot is enabled for %s', path) | redraw
    let b:copilot_enabled = v:true
  endif
endfunction

augroup my_copilot
  autocmd!
  autocmd VimEnter,BufNewFile,BufRead * call s:enable_copilot()
augroup END
