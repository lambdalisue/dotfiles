# Only intentional preferences belong here; application-owned values stay local.
{ homeDirectory }:
{
  model = "opus";
  effortLevel = "high";
  permissions = {
    allow = [
      "Bash(jj describe:*)"
      "Bash(jj new:*)"
      "Bash(jj split:*)"
      "Bash(jj squash:*)"
      "Bash(jj absorb:*)"
      "Bash(jj rebase:*)"
      "Bash(jj edit:*)"
      "Bash(jj restore:*)"
      "Bash(jj undo:*)"
      "Bash(jj git init:*)"
      "Bash(jj git fetch:*)"
      "Bash(jj workspace add:*)"
      "EnterWorktree"
    ];
    defaultMode = "auto";
  };
  sandbox = {
    enabled = true;
    # Entries match the literal command text, so a tilde path and its
    # expanded form are separate entries. The Arto opener has to leave the
    # sandbox because it starts the app through LaunchServices, which the
    # sandbox blocks.
    excludedCommands = [
      "~/.agents/skills/arto/open.sh *"
      "${homeDirectory}/.agents/skills/arto/open.sh *"
    ];
    # nix evaluates flakes through a SQLite cache under ~/.cache/nix; read-only
    # there, every `nix develop` fails with "attempt to write a readonly
    # database".
    filesystem.allowWrite = [ "${homeDirectory}/.cache/nix" ];
    # A multi-user install builds through the daemon, so nix needs its socket.
    network.allowUnixSockets = [ "/nix/var/nix/daemon-socket/socket" ];
  };
  hooks = {
    PreToolUse = [
      {
        matcher = "Write";
        hooks = [
          {
            type = "command";
            command = "~/.claude/hooks/warn-mod-rs.sh";
            timeout = 5;
          }
        ];
      }
      {
        matcher = "Bash";
        hooks = [
          {
            type = "command";
            command = "~/.claude/hooks/enforce-perl.sh";
            timeout = 5;
          }
          {
            type = "command";
            command = "~/.claude/hooks/enforce-jj.sh";
            timeout = 5;
          }
          {
            type = "command";
            command = "~/.claude/hooks/enforce-nix-path.sh";
            timeout = 5;
          }
        ];
      }
      {
        matcher = "Task|Agent";
        hooks = [
          {
            type = "command";
            command = "~/.claude/hooks/enforce-subagent-model.sh";
            timeout = 5;
          }
        ];
      }
    ];
  };
  statusLine = {
    type = "command";
    command = "bun x ccusage statusline";
    padding = 0;
  };
  enabledPlugins = {
    "gh-as@gh-as" = true;
    "rust-analyzer-lsp@claude-plugins-official" = true;
    "frontend-design@claude-plugins-official" = true;
    "lua-lsp@claude-plugins-official" = true;
    "probitas@probitas-test" = true;
    "swift-lsp@claude-plugins-official" = true;
    "cclens@cclens" = true;
    "kuchiyose@kuchiyose" = true;
    "figures@figures" = true;
    "vitro@vitro" = true;
  };
  extraKnownMarketplaces = {
    gh-as = {
      source = {
        source = "github";
        repo = "lambdalisue/gh-as";
      };
      autoUpdate = true;
    };
    probitas-test = {
      source = {
        source = "github";
        repo = "probitas-test/claude-plugins";
      };
    };
    cclens = {
      source = {
        source = "github";
        repo = "lambdalisue/cclens";
      };
      autoUpdate = true;
    };
    kuchiyose = {
      source = {
        source = "github";
        repo = "lambdalisue/kuchiyose";
      };
    };
    figures = {
      source = {
        source = "github";
        repo = "natsukium/claude-code-figures-plugin";
      };
    };
    vitro = {
      source = {
        source = "github";
        repo = "lambdalisue/vitro";
      };
      autoUpdate = true;
    };
  };
  pluginConfigs = {
    "agents-md@builtin" = {
      options = {
        instructionFiles = "claude-md-or-agents-md";
      };
    };
  };
  remoteControlAtStartup = true;
  agentPushNotifEnabled = true;
  inputNeededNotifEnabled = true;
  autoCompactEnabled = true;
  editorMode = "normal";
  theme = "auto";
  tui = "default";
  verbose = false;
  skipAutoPermissionPrompt = true;
  skipWorkflowUsageWarning = true;
}
