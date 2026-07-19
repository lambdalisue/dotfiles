# PATH — mirrors home/config/zsh/path.zsh.
#
# Collect the directories that exist, in priority order, then add them in a
# single fish_add_path call so their relative order is preserved (a per-dir
# loop would reverse it).
set -l extra_path
for dir in \
    $HOME/go/bin \
    $HOME/.bun/bin \
    $HOME/.deno/bin \
    $HOME/.cabal/bin \
    $HOME/.cargo/bin \
    $HOME/.poetry/bin \
    $HOME/.krew/bin \
    $HOME/.local/bin \
    $HOME/.local/share/aquaproj-aqua/bin \
    /opt/homebrew/opt/llvm/bin \
    /opt/homebrew/opt/libpq/bin \
    /opt/homebrew/bin \
    /opt/homebrew/sbin
    test -d $dir; and set -a extra_path $dir
end

# --path operates on $PATH directly (not $fish_user_paths, which fish always
# prepends). Inside a nix/direnv shell, append so nix-provided tools keep
# priority over ours; otherwise prepend so ours take priority. fish_add_path
# deduplicates and never moves an entry that is already present.
if set -q IN_NIX_SHELL
    test -n "$extra_path"; and fish_add_path --path -ga $extra_path
else
    test -n "$extra_path"; and fish_add_path --path -gp $extra_path
end

# pnpm
if test -d $HOME/Library/pnpm
    set -gx PNPM_HOME $HOME/Library/pnpm
    fish_add_path --path -gp $PNPM_HOME
end
