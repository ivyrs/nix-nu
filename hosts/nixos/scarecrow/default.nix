{ config, inputs, ... }:
{
  imports = [
    ./hardware.nix
    ./disko.nix
    inputs.disko.nixosModules.disko

    ../../../modules/system/nix
    ../../../modules/system/nix/nixos.nix
    ../../../modules/system/locale.nix
    ../../../modules/system/home-manager.nix

    ../../../modules/users/ivy.nix
    ../../../modules/services/ssh.nix
    ../../../modules/services/sops.nix
    ../../../modules/services/tailscale.nix
    ../../../modules/services/uptime-kuma.nix
  ];

  home-manager.users.ivy.imports = [
    ./home.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "scarecrow";
    useDHCP = true;

    firewall = {
      enable = true;
      allowedTCPPorts = [
        80
        443
      ];
    };
  };

  # Public edge: SSH must not be reachable off the tailnet.
  services.openssh.openFirewall = false;

  services.tailscale.useRoutingFeatures = "server";

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
    defaultSopsFile = ../../../secrets/scarecrow.yaml;

    secrets = {
      ivy-password-hash = {
        neededForUsers = true;
      };

      desec-token = {
        owner = "acme";
        group = "acme";
        mode = "0440";
      };
    };
  };

  users.users.ivy.hashedPasswordFile = config.sops.secrets.ivy-password-hash.path;

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "ivy@ivy.rs";
      dnsProvider = "desec";
      environmentFile = config.sops.secrets.desec-token.path;
    };
    certs."status.houseplants.cloud" = { };
  };

  services.caddy = {
    enable = true;
    email = "ivy@ivy.rs";

    virtualHosts."status.houseplants.cloud" = {
      extraConfig = ''
        reverse_proxy 127.0.0.1:3001
      '';
    };
  };
}
