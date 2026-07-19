# Run the docbase CLI (deno) forcing a fresh module download — zsh function.
function docbase-reload
    command deno run -r --allow-net --allow-read --allow-write --allow-env \
        jsr:@lambdalisue/docbase/cli/docbase $argv
end
