---
name: {{project}}
description: <!-- When Claude should use {{project}}, in the user's words. -->
---

# {{project}}

## Find the binary

1. Use `{{project}}` when it is on PATH.
2. Otherwise run it through Nix without installing anything:
   `nix run github:{{owner}}/{{project}} -- <args>`.
3. Without either, tell the user how to install it (see the README) and stop.
   Never install it on the user's behalf.

## Use

<!-- The commands Claude runs and how to read their output. Point to the
     repository's docs for the full guide instead of copying it here. -->
