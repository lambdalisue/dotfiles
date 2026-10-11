# Reload the fish configuration by replacing this shell with a fresh one
# (Ctrl-o r).
#
# Re-sourcing config files in place cannot drop bindings or functions that were
# removed from the files, so a new process is the only reliable reload.
function reload --description 'Reload the fish configuration by restarting the shell'
    exec fish
end
