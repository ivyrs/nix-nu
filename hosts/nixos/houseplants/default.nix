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
    ../../../modules/services/caddy
  ];

  home-manager.users.ivy.imports = [
    ./home.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "houseplants";
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
  # Keeps public IPv6 SLAAC working: routing "server" mode enables IP
  # forwarding, which otherwise silently disables SLAAC autoconf.
  boot.kernel.sysctl."net.ipv6.conf.all.accept_ra" = 2;
  boot.kernel.sysctl."net.ipv6.conf.default.accept_ra" = 2;

  system.stateVersion = "25.11";

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
    defaultSopsFile = ../../../secrets/houseplants.yaml;

    secrets.ivy-password-hash = {
      neededForUsers = true;
    };
  };

  users.users.ivy.hashedPasswordFile = config.sops.secrets.ivy-password-hash.path;
}
