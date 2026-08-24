{ inputs, ... }:
{
  imports = [
    ../../../home/shell
    ../../../home/git
    ../../../home/tmux

    inputs.nix-openclaw.homeManagerModules.openclaw
  ];

  # Headless box — plain neovim instead of the nvf config (kept off yew to
  # avoid the heavy build on a 2014 i3).
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
  };

  home = {
    username = "ivy";
    homeDirectory = "/home/ivy";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;

  # ── OpenClaw (Sorrel) ───────────────────────────────────────────────────────
  # Runs as a systemd *user* service. Secrets are read from sops-rendered files
  # at /run/secrets/* at runtime (nix-openclaw reads file-path env values), so
  # no keys land in the nix store.
  #
  # Workspace is deliberately NOT nix-managed (no workspace.bootstrapFiles): the
  # nix-nu remote is public and USER.md/MEMORY.md/IDENTITY.md are private. The
  # runtime workspace (~/.openclaw/workspace, migrated from alder) stays owned by
  # OpenClaw, not the flake.
  programs.openclaw = {
    enable = true;
    systemd.enable = true;

    # nix-openclaw enables goplaces by default, but the pinned tool's nested
    # flake lock contains a mutable path input that Nix 2.32 rejects. Sorrel
    # does not use Google Places, so keep the optional tool out of this host.
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

      # Only Ivy may issue owner commands.
      commands.ownerAllowFrom = [ 295975431058751498 ];
      session.dmScope = "per-channel-peer";

      # ── Model routing (the whole point) ──────────────────────────────────────
      # Capable model for real chats, cheap model for heartbeats/cron.
      # ⚠️ CONFIRM these OpenRouter slugs against openrouter.ai/models before we
      # rely on them — I've used plausible ids but not verified the live catalog.
      agents.defaults = {
        model = {
          primary = "openrouter/anthropic/claude-sonnet-4.5";
          fallbacks = [ "openrouter/anthropic/claude-haiku-4.5" ];
        };

        heartbeat = {
          every = "30m";
          model = "openrouter/anthropic/claude-haiku-4.5";
        };
      };

      # OpenCode Zen is available as a backup provider (OPENCODE_API_KEY is
      # wired above). Add it under models.providers once its baseUrl/api are
      # confirmed, then reference opencode/* models in fallbacks.
    };
  };

  # Start the gateway whenever ivy's user manager starts, including at boot
  # when linger is enabled by the NixOS user declaration.
  systemd.user.services.openclaw-gateway.Install.WantedBy = [ "default.target" ];
}
