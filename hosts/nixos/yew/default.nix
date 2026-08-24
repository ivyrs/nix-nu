{
  config,
  inputs,
  ...
}:
{
  imports = [
    ./hardware.nix

    ../../../modules/system/nix
    ../../../modules/system/nix/nixos.nix
    ../../../modules/system/locale.nix
    ../../../modules/system/home-manager.nix

    ../../../modules/users/ivy.nix
    ../../../modules/services/ssh.nix
    ../../../modules/services/sops.nix
    ../../../modules/services/tailscale.nix
  ];

  # nix-openclaw's stable Node embeds SQLite 3.51.2, which OpenClaw rejects
  # because of the upstream WAL-reset corruption bug. Source only Node from a
  # verified package revision whose cached build uses SQLite 3.53.3.
  nixpkgs.overlays = [
    (
      _final: prev:
      let
        safePkgs = inputs.safe-node-nixpkgs.legacyPackages.${prev.stdenv.hostPlatform.system};
      in
      {
        nodejs_22 = safePkgs.nodejs_24;
        "nodejs-slim_22" = safePkgs."nodejs-slim_24";
      }
    )
    inputs.nix-openclaw.overlays.default
  ];

  home-manager.users.ivy.imports = [
    ./home.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "yew";
    networkmanager.enable = true;
    firewall.enable = true;
  };

  system.stateVersion = "26.05";

  security.sudo.wheelNeedsPassword = true;

  users.users.deploy = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICtFawaAWSklr1GGYiBZzGr/ydKSSOatBfGfY72eqKGZ ivy@aspen"
    ];
  };

  security.sudo.extraRules = [
    {
      users = [ "deploy" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  sops = {
    defaultSopsFile = ../../../secrets/yew.yaml;

    secrets = {
      ivy-password-hash = {
        neededForUsers = true;
      };

      # Readable by the ivy user so the OpenClaw systemd *user* service can
      # load them at runtime (nix-openclaw reads file-path env values).
      discord-bot-token.owner = "ivy";
      openrouter-apikey.owner = "ivy";
      opencode-apikey.owner = "ivy";
      gateway-auth-token.owner = "ivy";
    };
  };

  users.users.ivy = {
    linger = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEdNudbGaj76Gu5Kn9bKsTCb8cAMPM0lg/hS6TriaWY7 ivy@alder"
    ];

    hashedPasswordFile = config.sops.secrets.ivy-password-hash.path;
  };
}
