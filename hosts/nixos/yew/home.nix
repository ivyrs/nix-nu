{ inputs, ... }:
{
  imports = [
    ../../../home/shell
    ../../../home/git
    ../../../home/tmux
    ../../../home/neovim/core.nix
    ../../../home/pim

    inputs.nix-openclaw.homeManagerModules.openclaw
  ];

  home = {
    username = "ivy";
    homeDirectory = "/home/ivy";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;

  programs.openclaw = {
    enable = true;
    systemd.enable = true;

    bundledPlugins.goplaces.enable = false;

    runtimePlugins = [ "discord" ];

    environment = {
      DISCORD_BOT_TOKEN = "/run/secrets/discord-bot-token";
      OPENROUTER_API_KEY = "/run/secrets/openrouter-apikey";
      OPENCODE_API_KEY = "/run/secrets/opencode-apikey";
      OPENCLAW_GATEWAY_TOKEN = "/run/secrets/gateway-auth-token";
    };

    config = {
      gateway = {
        mode = "local";
        bind = "loopback";
        auth = {
          mode = "token";
          token = {
            source = "env";
            provider = "default";
            id = "OPENCLAW_GATEWAY_TOKEN";
          };
        };
      };

      channels.discord = {
        enabled = true;
        token = {
          source = "env";
          provider = "default";
          id = "DISCORD_BOT_TOKEN";
        };
        groupPolicy = "open";
      };

      commands.ownerAllowFrom = [ "discord:295975431058751498" ];
      session = {
        dmScope = "per-channel-peer";
        reset = {
          mode = "idle";
          idleMinutes = 60;
        };
      };

      # Use Haiku for chats and background work to keep OpenRouter spend bounded.
      # Sonnet remains available for explicit model switches when needed.
      agents.defaults = {
        model = {
          primary = "openrouter/anthropic/claude-haiku-4.5";
          fallbacks = [ ];
        };

        heartbeat = {
          every = "0m";
          model = "openrouter/anthropic/claude-haiku-4.5";
        };
      };

      tools.allow = [
        "read"
        "write"
        "edit"
        "apply_patch"
        "exec"
        "process"
        "memory_search"
        "memory_get"
        "web_search"
        "web_fetch"
        "cron"
        "message"
        "session_status"
        "image"
      ];

      # OpenCode Zen is available as a backup provider (OPENCODE_API_KEY is
      # wired above). Add it under models.providers once its baseUrl/api are
      # confirmed, then reference opencode/* models in fallbacks.
    };
  };

  systemd.user.services.openclaw-gateway.Install.WantedBy = [ "default.target" ];
}
