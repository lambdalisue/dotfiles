# Run the docbase CLI (deno) — zsh function.
function docbase
    command deno run --allow-net --allow-read --allow-write --allow-env \
        jsr:@lambdalisue/docbase/cli/docbase $argv
end
