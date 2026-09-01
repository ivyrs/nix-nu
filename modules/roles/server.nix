{ config, lib, ... }:
{
  imports = [
    ../system/nix
    ../system/nix/nixos.nix
    ../system/locale.nix
    ../system/home-manager.nix

    ../users/ivy.nix
    ../services/ssh.nix
    ../services/sops.nix
    ../services/tailscale.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    networkmanager.enable = lib.mkDefault true;
    firewall.enable = true;
  };

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
    defaultSopsFile = ../../secrets/${config.networking.hostName}.yaml;
    secrets.ivy-password-hash.neededForUsers = true;
  };

  users.users.ivy.hashedPasswordFile = config.sops.secrets.ivy-password-hash.path;
}
