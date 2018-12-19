" <C-z> is used in tmux so remap it to <C-s>
call denite#custom#map('_', '<C-s>', '<denite:suspend>', 'noremap')

" Swap C-g/Down C-t/Up
call denite#custom#map('insert', '<C-n>', '<denite:assign_next_matched_text>', 'noremap')
call denite#custom#map('insert', '<C-p>', '<denite:assign_previous_matched_text>', 'noremap')
call denite#custom#map('insert', '<Down>', '<denite:assign_next_text>', 'noremap')
call denite#custom#map('insert', '<Up>', '<denite:assign_previous_text>', 'noremap')

" Emacs like mapping
call denite#custom#map('insert', '<C-f>', '<Right>')
call denite#custom#map('insert', '<C-b>', '<Left>')
call denite#custom#map('insert', '<C-a>', '<Home>')
call denite#custom#map('insert', '<C-e>', '<End>')
call denite#custom#map('insert', '<C-d>', '<Del>')

" Use <C-j>/<C-k> to select candidate
call denite#custom#map('insert', '<C-k>', '<denite:toggle_select_up>', 'noremap')
call denite#custom#map('insert', '<C-j>', '<denite:toggle_select_down>', 'noremap')

" Use regex matcher
call denite#custom#map('insert', '<C-^>', '<denite:toggle_matchers:matcher/regexp>', 'noremap')

" grep
if executable('pt')
  " Use pt (the platinum searcher)
  " https://github.com/monochromegane/the_platinum_searcher
  call denite#custom#var('grep', 'command', ['pt'])
  call denite#custom#var('grep', 'recursive_opts', [])
  call denite#custom#var('grep', 'final_opts', [])
  call denite#custom#var('grep', 'separator', [])
  call denite#custom#var('grep', 'default_opts', [
        \ '--nocolor', '--nogroup', '--column',
        \])

  call denite#custom#var('file_rec', 'command', [
        \ 'pt', '--follow', '--nocolor', '--nogroup',
        \ has('win32') ? '-g:' : '-g=',
        \ '',
        \])
endif

call denite#custom#option('_', 'cursor_wrap', v:true)
call denite#custom#source('_', 'matchers', ['matcher/substring'])

function! s:build_filemenu(description, precursors) abort
  let candidates = []
  for precursor in sort(a:precursors)
    let precursor = fnamemodify(expand(precursor), ':~')
    call add(candidates, [precursor, precursor])
  endfor
  let menu = {'description': a:description}
  let menu.file_candidates = candidates
  return menu
endfunction

let s:menus = {}
let s:menus.shortcut = s:build_filemenu('Shortcut menu:', [
      \ '$HOME/.homesick/repos/rook',
      \ '$HOME/Code/github.com/lambdalisue',
      \ '$MYVIM_HOME/',
      \ '$MYVIM_HOME/ftplugin/',
      \ '$MYVIM_HOME/syntax/',
      \ '$MYVIM_HOME/template/',
      \ '$HOME/.vimrc.local',
      \ '$HOME/.gvimrc.local',
      \ '$MYVIM_HOME/init.vim',
      \ '$MYVIM_HOME/ginit.vim',
      \ '$MYVIM_HOME/vimrc.min',
      \ '$MYVIM_HOME/filetype.vim',
      \ '$MYVIM_HOME/rc.d/ale.vim',
      \ '$MYVIM_HOME/rc.d/altr.vim',
      \ '$MYVIM_HOME/rc.d/lsp.vim',
      \ '$MYVIM_HOME/rc.d/gina.vim',
      \ '$MYVIM_HOME/rc.d/dein.toml',
      \ '$MYVIM_HOME/rc.d/denite.vim',
      \ '$MYVIM_HOME/rc.d/lexima.vim',
      \ '$MYVIM_HOME/rc.d/lightline.vim',
      \ '$MYVIM_HOME/rc.d/quickrun.vim',
      \ '$MYVIM_HOME/after/ftplugin/vim.vim',
      \ '$MYVIM_HOME/after/ftplugin/perl.vim',
      \ '$MYVIM_HOME/after/ftplugin/python.vim',
      \ '$MYVIM_HOME/after/ftplugin/jason.vim',
      \ '$MYVIM_HOME/after/ftplugin/terminal.vim',
      \ '$MYVIM_HOME/after/ftplugin/javascript.vim',
      \ '$MYVIM_HOME/after/ftplugin/typescript.vim',
      \ '$MYVIM_HOME/after/ftplugin/xslate.vim',
      \ '$MYVIM_HOME/after/ftplugin/help.vim',
      \ '$MYVIM_HOME/after/ftplugin/html.vim',
      \ '$MYVIM_HOME/after/ftplugin/qf.vim',
      \ '$HOME/.config/nyaovim/nyaovimrc.html',
      \ '$HOME/.config/nyaovim/browser-config.json',
      \ '$HOME/.themisrc',
      \ '$HOME/.config/zsh/',
      \ '$HOME/.config/zsh/rc.d/',
      \ '$HOME/.zshenv',
      \ '$HOME/.config/zsh/.zshrc',
      \ '$HOME/.config/zsh/zplug.zsh',
      \ '$HOME/.config/zsh/bookmark.txt',
      \ '$HOME/.config/zsh/rc.d/10_config.zsh',
      \ '$HOME/.config/zsh/rc.d/10_theme.zsh',
      \ '$HOME/.config/zsh/rc.d/20_keymap.zsh',
      \ '$HOME/.config/zsh/rc.d/50_config_peco.zsh',
      \ '$HOME/.config/zsh/rc.d/50_config_fzf.zsh',
      \ '$HOME/.config/zsh/rc.d/50_extend_rsync.zsh',
      \ '$HOME/.config/zsh/rc.d/90_functions.zsh',
      \ '$HOME/.config/tmux/',
      \ '$HOME/.config/tmux/tmux.conf',
      \ '$HOME/.config/tmux/rc.d/00_keymap.conf',
      \ '$HOME/.config/tmux/rc.d/50_plugin.conf',
      \ '$HOME/.config/karabiner/karabiner.json',
      \ '$HOME/.config/karabiner/assets/complex_modifications/pinkyless.json',
      \ '$HOME/.config/karabiner/assets/complex_modifications/terminal.json',
      \ '$HOME/.config/karabiner/assets/complex_modifications/virtualbox.json',
      \ '$HOME/.config/alacritty/alacritty.yml',
      \ '$HOME/.config/lemonade.toml',
      \ '$HOME/.config/kitty/kitty.conf',
      \ '$HOME/.gitconfig.local',
      \ '$HOME/.gitconfig',
      \ '$HOME/.gitignore',
      \ '$HOME/.hyper.js',
      \ '$HOME/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1',
      \ 'https://raw.githubusercontent.com/codemirror/CodeMirror/HEAD/keymap/vim.js',
      \])
call denite#custom#var('menu', 'menus', s:menus)
