---
name: doc-check
allowed-tools: Bash(npx:*), Bash(deno:*), Bash(ls:*), Bash(test:*)
description: Run format, lint, and spell check for documentation
---

## Workflow

1. **Detect** - Check if `deno.json` or `deno.jsonc` exists.
2. **Format** - Run formatter (sequential):
   - Deno project: `deno fmt "**/*.md"`
   - Otherwise: `npx prettier --write "**/*.md"`
3. **Check** - Run only the checks the project is actually configured for (skip — with a note — when a tool's config is absent, to avoid `npx` downloading/running an unconfigured tool). Run the enabled ones in parallel:
   - **textlint** — only if a config exists (`.textlintrc`, `.textlintrc.*`, or a `textlint` key in `package.json`): `npx --no-install textlint "**/*.md"`
   - **cspell** — only if a config exists (`cspell.json`, `.cspell.json`, `.cspell.jsonc`, or `cspell.config.*`): `npx --no-install cspell "**/*.md"`
4. **Summarize** - Deduplicate and report issues. List any checks that were skipped because no config was found.

## Begin

Detect project type, run the appropriate formatter, then run only the configured checks. Summarize unique issues and note skipped checks.
