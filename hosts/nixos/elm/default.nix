{ metadata, ... }:
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
    ../../../modules/services/owncast.nix
  ];

  home-manager.users.${metadata.user.username}.imports = [
    ./home.nix
  ];

  networking.hostName = metadata.hosts.elm.name;

  system.stateVersion = "25.11";
}
