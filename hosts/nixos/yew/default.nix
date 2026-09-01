{ ... }:
{
  imports = [
    ./hardware.nix

    ../../../modules/roles/server.nix
    ../../../modules/services/atuin-sync.nix
  ];

  home-manager.users.ivy.imports = [
    ./home.nix
  ];

  networking.hostName = "yew";

  system.stateVersion = "26.05";

  users.users.ivy.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEdNudbGaj76Gu5Kn9bKsTCb8cAMPM0lg/hS6TriaWY7 ivy@alder"
  ];
}
