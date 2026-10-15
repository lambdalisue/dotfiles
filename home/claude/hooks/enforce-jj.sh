#!/bin/bash
# Hook to enforce jj instead of history-writing git commands.
# Reads tool call JSON from stdin and validates Bash commands.
#
# A git command that writes history, the index, refs, or worktrees is blocked
# inside any Git repository. Read-only git (log, diff, show, blame, ...) and
# `git clone` / `git init` pass. Whether the repository already has `.jj`
# only changes the hint: a plain Git checkout is told to colocate jj first.

set -euo pipefail

input=$(cat)

if ! command -v jq &>/dev/null; then
    exit 0
fi

tool_name=$(echo "$input" | jq -r '.tool_name // ""')
command=$(echo "$input" | jq -r '.tool_input.command // ""')
cwd=$(echo "$input" | jq -r '.cwd // ""')

if [[ "$tool_name" != "Bash" ]] || [[ -z "$command" ]]; then
    exit 0
fi

CMD="$command" CWD="${cwd:-$PWD}" exec perl -e '
    use strict;
    use warnings;
    use File::Spec;

    my $c = $ENV{CMD};

    # --- quote-aware split into command segments -------------------------
    my (@seg, $cur, $q);
    $cur = ""; $q = "";
    my @ch = split //, $c;
    for (my $i = 0; $i < @ch; $i++) {
        my $ch = $ch[$i];
        if ($q ne "") {
            $cur .= $ch;
            if ($ch eq "\\" && $q eq chr(34)) { $cur .= ($ch[++$i] // ""); next; }
            $q = "" if $ch eq $q;
            next;
        }
        if ($ch eq chr(39) || $ch eq chr(34)) { $q = $ch; $cur .= $ch; next; }
        last if $ch eq "#" && ($cur eq "" || $cur =~ /\s$/);   # comment
        if ($ch =~ /[|&;()\n`]/) { push @seg, $cur; $cur = ""; next; }
        $cur .= $ch;
    }
    push @seg, $cur;

    # --- words of one segment, quotes removed ----------------------------
    sub words {
        my $s = shift;
        my @w;
        while ($s =~ /\G\s*((?:\x27[^\x27]*\x27|"(?:\\.|[^"\\])*"|[^\s\x27"]+)+)/gc) {
            my $w = $1;
            $w =~ s/\x27([^\x27]*)\x27/$1/g;
            $w =~ s/"((?:\\.|[^"\\])*)"/$1/g;
            push @w, $w;
        }
        return @w;
    }

    # --- the repository a directory belongs to ---------------------------
    sub repo_kind {
        my $dir = shift;
        $dir = File::Spec->rel2abs($dir, $ENV{CWD});
        while (1) {
            return "jj"  if -d "$dir/.jj";
            return "git" if -e "$dir/.git";
            my $parent = File::Spec->catdir($dir, File::Spec->updir);
            $parent = Cwd::abs_path($parent) // return "";
            return "" if $parent eq $dir;
            $dir = $parent;
        }
    }
    use Cwd ();

    my %hint = (
        commit       => "jj describe -m \"<message>\" / jj new -m \"<message>\" (no staging step)",
        add          => "nothing to stage: jj snapshots the working copy on every command",
        rm           => "plain rm; jj records the deletion",
        mv           => "plain mv; jj records the rename",
        reset        => "jj restore <paths> / jj abandon <rev> / jj new <rev>; undo with jj undo",
        restore      => "jj restore <paths> (from @-) or jj restore --from <rev> <paths>",
        checkout     => "jj new <rev> (or jj edit <rev>); files: jj restore --from <rev> <paths>",
        switch       => "jj new <rev> (or jj edit <rev>)",
        rebase       => "jj rebase -b @ -o \x27trunk()\x27 (the jj-rebase skill); reword: jj describe -r <rev> -m",
        merge        => "jj new <rev1> <rev2>",
        "cherry-pick"=> "jj duplicate <rev> -o @",
        revert       => "jj revert -r <rev> -o @",
        stash        => "jj new <base>; the current change stays where it is",
        pull         => "jj git fetch, then jj rebase -b @ -o \x27trunk()\x27",
        push         => "jj git push -b <bookmark> / jj git push -c <rev> (only when the user asked)",
        am           => "git apply <patch> (working tree only), then describe the change",
        tag          => "jj tag set <name> -r <rev>",
        branch       => "jj bookmark create/move/delete/list",
        worktree     => "jj workspace add --name <name> -r \x27trunk()\x27 .claude/worktrees/<name>",
        wt           => "jj workspace add --name <name> -r \x27trunk()\x27 .claude/worktrees/<name>",
        backup       => "nothing to back up: jj op log / jj undo / jj op restore <op>",
    );

    sub blocked {
        my ($sub, @args) = @_;
        return 0 unless exists $hint{$sub};
        my %a = map { $_ => 1 } @args;
        if ($sub eq "branch") {
            return 1 if grep { /^(?:-[dDmMcCfu]|--delete|--move|--copy|--force|--set-upstream-to.*|--unset-upstream|--edit-description)$/ } @args;
            return 0 if grep { /^(?:-[alrv]+|--list|--all|--remotes|--show-current|--contains|--no-contains|--merged|--no-merged|--points-at|--format.*|--sort.*|-vv)$/ } @args;
            return scalar grep { !/^-/ } @args;
        }
        if ($sub eq "tag") {
            return 1 if grep { /^(?:-[dfasmu]|--delete|--force|--annotate|--sign)$/ } @args;
            return 0 if grep { /^(?:-l|--list|-n\d*|--contains|--no-contains|--merged|--no-merged|--points-at|--sort.*|--format.*)$/ } @args;
            return scalar grep { !/^-/ } @args;
        }
        if ($sub eq "worktree") {
            return (($args[0] // "") =~ /^(?:add|remove|move|prune|repair|lock|unlock)$/) ? 1 : 0;
        }
        if ($sub eq "stash") {
            return (($args[0] // "") =~ /^(?:list|show)$/) ? 0 : 1;
        }
        return 1;
    }

    for my $seg (@seg) {
        my @w = words($seg);
        shift @w while @w && $w[0] =~ /^\w+=/;          # VAR=val prefixes
        shift @w while @w && $w[0] =~ /^(?:sudo|env|time|nice|nohup|command|builtin|exec|xargs)$/;
        next unless @w && $w[0] eq "git";
        shift @w;

        my $dir = $ENV{CWD};
        while (@w && $w[0] =~ /^-/) {
            my $o = shift @w;
            if    ($o eq "-C")                         { my $d = shift @w // ""; $dir = File::Spec->rel2abs($d, $dir); }
            elsif ($o eq "-c")                         { shift @w; }
            elsif ($o =~ /^--(?:git-dir|work-tree|namespace|exec-path)$/) { shift @w; }
        }
        my $sub = shift @w // "";
        next unless blocked($sub, @w);

        my $kind = repo_kind($dir);
        next if $kind eq "";

        my $msg = "❌ `git $sub` writes history — this repository is driven with jj.\n\n";
        if ($kind eq "git") {
            $msg .= "This Git repository has no .jj yet. Colocate jj once:\n  jj git init --colocate\nThen use:\n";
        } else {
            $msg .= "Use instead:\n";
        }
        $msg .= "  $hint{$sub}\n\n";
        $msg .= "See ~/.claude/rules/jj/workflow.md for the describe-first loop and\n";
        $msg .= "the Git-to-jj table. Read-only git (log, diff, show, blame) is allowed.\n";
        print STDERR $msg;
        exit 2;
    }
    exit 0;
'
