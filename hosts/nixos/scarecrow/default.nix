{
  config,
  inputs,
  metadata,
  ...
}:
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

  home-manager.users.${metadata.user.username}.imports = [
    ./home.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = metadata.hosts.scarecrow.name;
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
      "${metadata.user.sshKeys.aspen} ${metadata.user.username}@${metadata.hosts.aspen.name}"
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

  users.users.${metadata.user.username}.hashedPasswordFile =
    config.sops.secrets.ivy-password-hash.path;

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = metadata.user.emails.primary;
      dnsProvider = "desec";
      environmentFile = config.sops.secrets.desec-token.path;
    };
    certs."status.${metadata.domains.services}" = { };
  };

  services.caddy = {
    enable = true;
    email = metadata.user.emails.primary;

    virtualHosts."status.${metadata.domains.services}" = {
      extraConfig = ''
        reverse_proxy 127.0.0.1:3001
      '';
    };
  };
}
