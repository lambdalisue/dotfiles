{ config, pkgs, ... }:
let
  # gh-as: run a gh command as the account a repository belongs to, without
  # `gh auth switch` rewriting the machine-wide active account. Fetched by tag
  # rather than vendored so the copy here cannot drift from the published one.
  gh-as = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "gh-as";
    version = "0.1.0";

    src = pkgs.fetchFromGitHub {
      owner = "lambdalisue";
      repo = "gh-as";
      tag = "v${finalAttrs.version}";
      hash = "sha256-UZ0DsrIe9MfNvoOVsvfRbBHa9qz2I0P0WdJfUjQjHKg=";
    };

    dontBuild = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 gh-as $out/bin/gh-as
      runHook postInstall
    '';

    meta = {
      description = "Run a command as one of the GitHub accounts gh is logged in with";
      homepage = "https://github.com/lambdalisue/gh-as";
      license = pkgs.lib.licenses.mit;
      mainProgram = "gh-as";
    };
  });
in
{
  # GitHub CLI and its extensions, managed declaratively.
  #
  # programs.gh writes ~/.config/gh/config.yml (settings below). Authentication
  # lives in hosts.yml, which is left untouched because `hosts` is unset.
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "https";
      aliases = {
        co = "pr checkout";
      };
    };
    extensions = [
      pkgs.gh-poi # `gh poi`: safely clean up merged local branches
      gh-as # `gh as`: run a command as a chosen account
    ];
  };

  # `gh` rewrites config.yml itself — `gh auth login` persists the chosen git
  # protocol there — and fails with "permission denied" on the read-only store
  # symlink programs.gh links in. Seed the very same generated file as a writable
  # copy instead; see nix/home/mutable-files.nix.
  xdg.configFile."gh/config.yml".enable = false;
  home.mutableFile."${config.xdg.configHome}/gh/config.yml".source =
    config.xdg.configFile."gh/config.yml".source;
}
