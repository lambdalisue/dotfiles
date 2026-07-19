# Interactive-only setup: prompt configuration, tool integrations and
# abbreviations. Runs after 00-env.fish / 10-path.fish (filename order), so
# PATH and the environment are already in place here.
if status is-interactive
    # No startup greeting (matches the previous zsh setup).
    set -g fish_greeting ''

    # Prompt (collon): show upstream ahead/behind as `^` / `v`, full cwd path.
    set -g __fish_git_prompt_showupstream informative
    set -g __fish_git_prompt_char_upstream_prefix ''
    set -g __fish_git_prompt_char_upstream_ahead '^'
    set -g __fish_git_prompt_char_upstream_behind 'v'
    set -g __fish_git_prompt_char_upstream_equal ''
    set -g fish_prompt_pwd_dir_length 0

    # Disable Ctrl-S / Ctrl-Q flow control (frees them for editing)
    stty -ixon 2>/dev/null

    # fzf
    if type -q fzf
        set -gx FZF_DEFAULT_OPTS '
            --exact
            --border
            --reverse
            --height=40%
            --bind=ctrl-t:up,ctrl-g:down
            '
        if type -q fd
            set -gx FZF_DEFAULT_COMMAND 'fd --type f'
        end
    end

    # direnv
    if type -q direnv
        direnv hook fish | source
    end

    # mise
    if type -q mise
        mise activate fish | source
    end

    # git-wt (cd after `git wt <branch>`)
    if type -q git-wt
        git wt --init fish | source
    end

    # kubectl completions
    if type -q kubectl
        kubectl completion fish | source
    end

    # Minimal-config editors (zsh: alias nvimm / vimm). abbr expands inline.
    if type -q nvim
        abbr -a nvimm 'nvim -u ~/.vim/vimrc.min -i NONE'
    end
    if type -q vim
        abbr -a vimm 'vim -u ~/.vim/vimrc.min -i NONE'
    end
end
