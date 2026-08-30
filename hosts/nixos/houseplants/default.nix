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
    ../../../modules/services/xmpp
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

    # dhcpcd doesn't reliably populate /etc/resolv.conf before tailscaled
    # takes over DNS management, leaving tailscaled with no fallback
    # resolver for non-tailnet domains. Declare these statically instead.
    nameservers = [
      "185.12.64.2" # Hetzner recursive resolver
      "185.12.64.1"
    ];

    interfaces.enp1s0.ipv6.addresses = [
      {
        address = "2a01:4f8:c17:7da9::1";
        prefixLength = 64;
      }
    ];

    defaultGateway6 = {
      address = "fe80::1";
      interface = "enp1s0";
    };

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
    certs = {
      "ivy.rs" = { };
      "houseplants.cloud" = {
        extraDomainNames = [ "conference.houseplants.cloud" ];
      };
      "xmpp.houseplants.cloud" = { };
    };
  };
}
