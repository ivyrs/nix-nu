{ metadata, ... }:
{
  imports = [
    ./hardware.nix

    ../../../modules/roles/server.nix
    ../../../modules/services/atuin-sync.nix
  ];

  home-manager.users.${metadata.user.username}.imports = [
    ./home.nix
  ];

  networking.hostName = metadata.hosts.yew.name;

  system.stateVersion = "26.05";

  users.users.${metadata.user.username}.openssh.authorizedKeys.keys = [
    "${metadata.user.sshKeys.alder} ${metadata.user.username}@${metadata.hosts.alder.name}"
  ];
}
