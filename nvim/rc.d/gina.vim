call gina#custom#command#option(
      \ 'commit', '-v|--verbose'
      \)
call gina#custom#command#option(
      \ '/\%(status\|commit\)',
      \ '-u|--untracked-files'
      \)
call gina#custom#command#option(
      \ 'status',
      \ '-b|--branch'
      \)
call gina#custom#command#option(
      \ 'status',
      \ '-s|--short'
      \)
call gina#custom#command#option(
      \ '/\%(commit\|tag\)',
      \ '--restore'
      \)
call gina#custom#command#option(
      \ 'show',
      \ '--show-signature'
      \)

call gina#custom#action#alias(
      \ 'branch', 'track',
      \ 'checkout:track'
      \)
call gina#custom#action#alias(
      \ 'branch', 'merge',
      \ 'commit:merge'
      \)
call gina#custom#action#alias(
      \ 'branch', 'rebase',
      \ 'commit:rebase'
      \)

call gina#custom#mapping#nmap(
      \ 'branch', 'g<CR>',
      \ '<Plug>(gina-commit-checkout-track)'
      \)
call gina#custom#mapping#nmap(
      \ 'status', '<C-^>',
      \ ':<C-u>Gina commit<CR>',
      \ {'noremap': 1, 'silent': 1}
      \)
call gina#custom#mapping#nmap(
      \ 'commit', '<C-^>',
      \ ':<C-u>Gina status<CR>',
      \ {'noremap': 1, 'silent': 1}
      \)
call gina#custom#mapping#nmap(
      \ 'status', '<C-6>',
      \ ':<C-u>Gina commit<CR>',
      \ {'noremap': 1, 'silent': 1}
      \)
call gina#custom#mapping#nmap(
      \ 'commit', '<C-6>',
      \ ':<C-u>Gina status<CR>',
      \ {'noremap': 1, 'silent': 1}
      \)

call gina#custom#action#alias(
      \ '/\%(blame\|log\|reflog\)',
      \ 'preview',
      \ 'topleft show:commit:preview',
      \)
call gina#custom#mapping#nmap(
      \ '/\%(blame\|log\|reflog\)',
      \ 'p',
      \ ':<C-u>call gina#action#call(''preview'')<CR>',
      \ {'noremap': 1, 'silent': 1}
      \)

call gina#custom#action#alias(
      \ '/\%(blame\|log\|reflog\)',
      \ 'changes',
      \ 'topleft changes:of:preview',
      \)
call gina#custom#mapping#nmap(
      \ '/\%(blame\|log\|reflog\)',
      \ 'c',
      \ ':<C-u>call gina#action#call(''changes'')<CR>',
      \ {'noremap': 1, 'silent': 1}
      \)

call gina#custom#execute(
      \ '/\%(ls\|log\|reflog\|grep\)',
      \ 'setlocal noautoread',
      \)
call gina#custom#execute(
      \ '/\%(status\|branch\|ls\|log\|reflog\|grep\)',
      \ 'setlocal cursorline',
      \)
