# fish entry point (migrated from home/config/zsh).
#
# The configuration is split into modular drop-ins under conf.d/ — which fish
# sources automatically, in filename order, BEFORE this file — and autoloaded
# functions under functions/:
#
#   conf.d/00-env.fish          environment variables (all shells)
#   conf.d/10-path.fish         PATH (all shells)
#   conf.d/20-interactive.fish  interactive-only setup (prompt, tool hooks,
#                               fzf, abbreviations)
#   conf.d/recent_dirs.fish     records visited dirs for the _fzf_cdr widget
#   functions/                  prompt, keybindings, fzf widgets, ls/la,
#                               docbase, ...
#
# fish provides autosuggestions and syntax highlighting natively, so the zsh
# addons (zsh-autosuggestions / fast-syntax-highlighting) are intentionally
# dropped.
#
# Nothing needs to live here; keep this file for local, machine-specific
# overrides only.
