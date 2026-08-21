{
  imports = [
    ./hardware.nix

    ../../../modules/system/nix
    ../../../modules/system/nix/nixos.nix
    ../../../modules/system/locale.nix
    ../../../modules/system/home-manager.nix

    ../../../modules/users/ivy.nix
    ../../../modules/services/ssh.nix
    ../../../modules/services/tailscale.nix
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
}
