{ config, lib, ... }:
{
  imports = [
    ../system/nix
    ../system/nix/nixos.nix
    ../system/locale.nix
    ../system/home-manager.nix

    ../users/ivy.nix
    ../users/deploy.nix
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

  sops = {
    defaultSopsFile = ../../secrets/${config.networking.hostName}.yaml;
    secrets.ivy-password-hash.neededForUsers = true;
  };

  users.users.ivy.hashedPasswordFile = config.sops.secrets.ivy-password-hash.path;
}
