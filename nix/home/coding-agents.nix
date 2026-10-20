{
  config,
  lib,
  pkgs,
  dotfilesDir,
  isDarwin,
  ...
}:
let
  link = config.lib.file.mkOutOfStoreSymlink;
  # Flakes contain only tracked sources, so downloaded/synced skills are not
  # enrolled in Home Manager just because an application installed them.
  skills = lib.attrNames (
    lib.filterAttrs (_: type: type == "directory") (builtins.readDir ../../home/claude/skills)
  );
  claudeAssets = [
    "CLAUDE.md"
    "agents"
    "hooks"
    "mcp.json"
    "rules"
  ]
  ++ map (name: "skills/${name}") skills;
  codexAssets = [ "AGENTS.md" ];
  agents =
    map
      (agent: {
        source = "${dotfilesDir}/home/${agent.name}";
        target = "${config.home.homeDirectory}/.${agent.name}";
        managed = agent.assets;
      })
      [
        {
          name = "claude";
          assets = claudeAssets;
        }
        {
          name = "codex";
          assets = codexAssets;
        }
      ];
  migrationManifest = pkgs.writeText "coding-agent-directories.json" (builtins.toJSON agents);
  assetFiles =
    agent: paths:
    lib.genAttrs (map (path: ".${agent}/${path}") paths) (path: {
      source = link "${dotfilesDir}/home/${agent}/${lib.removePrefix ".${agent}/" path}";
      # Legacy whole-directory links expose the source files during collision
      # checks. Migration separates the directories before linkGeneration.
      force = true;
    });
in
{
  programs.claude-code = {
    enable = true;
    package = if isDarwin then null else pkgs.claude-code;
    mutableSettings = true;
    settings = import ./claude-settings.nix;
  };

  programs.codex = {
    enable = true;
    mutableSettings = true;
    settings = {
      model = "gpt-6.1-sol";
      model_reasoning_effort = "medium";
      approval_policy = "on-request";
      approvals_reviewer = "auto_review";
      sandbox_mode = "workspace-write";
      features = {
        js_repl = false;
        memories = true;
        chronicle = true;
      };
      memories = {
        generate_memories = true;
        use_memories = true;
      };
      plugins =
        lib.genAttrs
          [
            "frontend-design@claude-plugins-official"
            "lua-lsp@claude-plugins-official"
            "rust-analyzer-lsp@claude-plugins-official"
            "probitas@probitas-test"
          ]
          (_: {
            enabled = true;
          });
      marketplaces = {
        claude-plugins-official = {
          source_type = "git";
          source = "https://github.com/anthropics/claude-plugins-official.git";
        };
        probitas-test = {
          source_type = "git";
          source = "https://github.com/probitas-test/claude-plugins.git";
        };
      };
    };
  };

  home.file = assetFiles "claude" claudeAssets // assetFiles "codex" codexAssets;

  # Move state by rename, preserving open files and old absolute plugin paths.
  # The latter become compatibility links back to the real home directories.
  home.activation.migrateCodingAgentState =
    lib.hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ]
      ''
        run ${lib.getExe pkgs.python3} ${../../scripts/migrate-agent-state.py} ${migrationManifest} \
          ''${DRY_RUN_CMD:+--dry-run}
      '';
}
