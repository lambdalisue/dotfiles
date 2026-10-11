# Keybindings — mirrors the zsh `bindkey` setup. fish calls this automatically
# on startup (after the default emacs bindings, which we keep as the base).
#
# NOTE: fish 4 uses named keys and comma-separated chords (e.g. `ctrl-x,ctrl-g`),
# not the old `\cx\cg` escape notation — the latter silently fails to bind.
function fish_user_key_bindings
    # Complete word with Ctrl-k (zsh: forward-word)
    bind ctrl-k forward-word

    # Prefix history search with Ctrl-p / Ctrl-n (zsh: history-beginning-search)
    bind ctrl-p history-prefix-search-backward
    bind ctrl-n history-prefix-search-forward

    # Edit the command line in $EDITOR with Ctrl-o e (zsh: edit-command-line)
    bind ctrl-o,e edit_command_buffer

    # Delete a path component with Ctrl-w (zsh: WORDCHARS excluded `/`)
    bind ctrl-w backward-kill-path-component

    # Do not log out on Ctrl-d when the line is empty (zsh: IGNOREEOF)
    bind ctrl-d delete-char

    # fzf widgets (zsh: abindkey ...)
    #
    # Chords live under Ctrl-o rather than Ctrl-x: with Caps Lock as Ctrl,
    # Ctrl-x Ctrl-<key> keeps the left pinky down through two left-hand keys,
    # while Ctrl-o splits the prefix across both hands and the second key is
    # pressed without Ctrl. Ctrl-o is free in fish's emacs preset.
    bind ctrl-r _fzf_history
    bind ctrl-o,o _fzf_menu
    bind ctrl-o,d _fzf_cdr
    bind ctrl-o,k _fzf_kill
    bind ctrl-o,g _fzf_ghq
    bind ctrl-o,w _fzf_worktree
    bind ctrl-o,p _fzf_k8s_pods

    # Reload the configuration with Ctrl-o r
    bind ctrl-o,r reload
end
