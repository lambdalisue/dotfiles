# Third-party Homebrew taps used across this flake.
#
# Consumed by two module trees, so the tap set and its trust never drift:
#   - nix/darwin/homebrew.nix       -> homebrew.taps (taps the machine installs)
#   - nix/home/homebrew-trust.nix   -> the trust.json that lets `brew` load them
#
# Homebrew refuses to load formulae/casks from an untrusted third-party tap, and
# trust is granted at the tap level (trusting a tap implicitly trusts every
# formula and cask it ships). Adding a tap here therefore both installs it and
# trusts it, in the activation and interactive `brew` contexts alike.
[
  "k1low/tap"
  # OmniWM ships only from its author's tap, not homebrew/cask.
  "barutsrb/tap"
  # Arto is distributed only from its author's tap, not homebrew/cask.
  "arto-app/tap"
  # PortKiller (CedricEugeni's native menubar app) ships from its own tap.
  "cedriceugeni/portkiller"
]
