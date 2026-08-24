{ config, ... }:
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

    ../../../modules/services/syncthing.nix
    ../../../modules/services/pocket-id.nix
    ../../../modules/services/miniflux.nix
    ../../../modules/services/vaultwarden.nix
    ../../../modules/services/gotosocial
    ../../../modules/services/forgejo.nix
    ../../../modules/services/glance
    ../../../modules/services/irc
    ../../../modules/services/nextcloud.nix
  ];

  home-manager.users.ivy.imports = [
    ./home.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "elm";
    networkmanager.enable = true;
    firewall.enable = true;
  };

  system.stateVersion = "25.11";

  sops = {
    defaultSopsFile = ../../../secrets/elm.yaml;

    secrets.ivy-password-hash = {
      neededForUsers = true;
    };
  };

  security.sudo.wheelNeedsPassword = true;
  users.users.ivy.hashedPasswordFile = config.sops.secrets.ivy-password-hash.path;
}
