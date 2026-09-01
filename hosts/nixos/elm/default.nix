{ ... }:
{
  imports = [
    ./hardware.nix

    ../../../modules/roles/server.nix

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

  networking.hostName = "elm";

  system.stateVersion = "25.11";
}
