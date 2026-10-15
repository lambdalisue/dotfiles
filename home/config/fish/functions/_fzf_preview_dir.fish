# Preview a directory for the cd-style fzf widgets: a header with the path and
# git state, then the README rendered, or a tree of the contents when there is
# no README.
#
# fzf runs the preview through $SHELL, which is not fish, so the widgets call
# this as `fish -c '_fzf_preview_dir {}'`. Output is not a TTY there, hence the
# forced colors throughout.
function _fzf_preview_dir --argument-names dir --description 'Preview a directory for fzf'
    set dir (string replace -r '^~' $HOME -- $dir)
    if not test -d "$dir"
        set_color red
        echo "No such directory: $dir"
        set_color normal
        return
    end
    set -q FZF_PREVIEW_COLUMNS; or set -l FZF_PREVIEW_COLUMNS 80

    set_color --bold blue
    echo ' '(string replace -r "^\Q$HOME\E" '~' -- $dir)
    set_color normal

    # A colocated jj repository is also a git work tree whose HEAD is always
    # detached, so ask jj first. jj finds the workspace from the cwd (-R accepts
    # only a workspace root), and the preview runs in its own fish process, so
    # the cd leaks nowhere.
    set -l branch
    set -l changes
    set -l last
    cd $dir
    if type -q jj; and _jj_in_workspace
        set branch (_jj_prompt)
        set changes (count (jj diff --quiet --summary 2>/dev/null))
        # The newest change that says something: @ itself unless it is still
        # empty and undescribed.
        set last (jj log --quiet --no-graph --color=never \
            -r 'heads(::@ ~ (empty() & description(exact:"")))' \
            -T 'committer.timestamp().ago() ++ " · " ++ description.first_line()' 2>/dev/null)
    else if git -C $dir rev-parse --is-inside-work-tree >/dev/null 2>&1
        set branch (git -C $dir branch --show-current)
        test -n "$branch"; or set branch (git -C $dir rev-parse --short HEAD 2>/dev/null)
        set changes (count (git -C $dir status --porcelain 2>/dev/null))
        set last (git -C $dir log -1 --format='%cr · %s' 2>/dev/null)
    end

    if test -n "$branch"
        set_color magenta
        echo -n "  $branch"
        if test $changes -eq 0
            set_color green
            echo -n '  ✓ clean'
        else
            set_color yellow
            echo -n "  ● $changes changed"
        end
        set_color normal
        echo
        if test -n "$last"
            set_color brblack
            echo "  $last" | string shorten -m $FZF_PREVIEW_COLUMNS
            set_color normal
        end
    end

    set_color brblack
    string repeat -n $FZF_PREVIEW_COLUMNS ─
    set_color normal

    # Prefer a Markdown README when several exist (README.md over README.txt).
    set -l readmes
    for path in $dir/*
        string match -qir '^readme(\.[a-z]+)?$' -- (path basename $path); and test -f $path; and set -a readmes $path
    end
    set -l readme (string match -eir '\.(md|markdown)$' -- $readmes)[1]
    test -n "$readme"; or set readme $readmes[1]

    if test -n "$readme"
        if string match -qir '\.(md|markdown)$' -- $readme; and type -q glow
            # Tidy the Markdown before glow sees it, outside fenced code only:
            # - glow prints every link and image with its URL, so images
            #   (badges, mostly) are dropped and links keep only their text;
            #   task-list checkboxes (`[ ]`, `[x]`) are left alone.
            # - glow keeps the source's soft line breaks, so paragraphs are
            #   unwrapped here. Its own wrapping is off (--width=0) because it
            #   breaks words early in narrow panes; the widgets let fzf wrap
            #   the preview by word instead.
            perl -e '
                my ($fence, @out) = (0);
                while (my $line = <>) {
                    chomp $line;
                    if ($line =~ /^\s*(?:```|~~~)/) { $fence = !$fence; push @out, $line; next }
                    if ($fence) { push @out, $line; next }
                    next if $line =~ /^ {0,3}\[[^\]]+\]:\s*\S/;
                    $line =~ s/\[!\[[^\]]*\]\([^)]*\)\]\([^)]*\)//g;
                    $line =~ s/!\[[^\]]*\]\([^)]*\)//g;
                    $line =~ s/\[([^\]]+)\](?:\([^)]*\)|\[[^\]]*\])/$1/g;
                    $line =~ s/\[(?![ xX]\])([^\]]+)\]/$1/g;
                    my $prev = @out ? $out[-1] : "";
                    if ($prev =~ /\S/ && $prev !~ /^\s*(?:#|```|~~~|\||<)|(?:  |\x5c)$/
                        && $line =~ /^\s*\S/
                        && $line !~ /^\s*(?:[-*+]\s|\d+[.)]\s|#|>|\||<|(?:[-=*_]\s*){3,}$)/) {
                        $line =~ s/^\s+//;
                        $out[-1] =~ s/\s+$//;
                        $out[-1] .= " $line";
                        next;
                    }
                    push @out, $line;
                }
                print "$_\n" for @out;
            ' $readme | CLICOLOR_FORCE=1 glow --style=$__fish_config_dir/glow-preview.json --width=0 -
        else if type -q bat
            bat --color=always --style=plain --terminal-width=$FZF_PREVIEW_COLUMNS $readme
        else
            cat $readme
        end
    else if type -q eza
        eza --tree --level=2 --all --ignore-glob=.git --git-ignore \
            --group-directories-first --icons=always --color=always $dir/
    else
        ls -AG $dir/
    end
end
