{ ... }:

{
  imports = [
    ./hardware.nix

    ../../../modules/hardware/apple-silicon.nix

    ../../../modules/system/nix
    ../../../modules/system/nix/nixos.nix
    ../../../modules/system/nix/cachix.nix

    ../../../modules/users/ivy.nix

    ../../../modules/services/ssh.nix
    ../../../modules/services/sops.nix
    ../../../modules/services/tailscale.nix

    ../../../modules/services/ly.nix
    ../../../modules/desktop/niri.nix
    ../../../modules/desktop/portals.nix
    ../../../modules/desktop/audio.nix

    ../../../modules/system/home-manager.nix
  ];

  networking = {
    hostName = "alder";

    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };

    firewall.enable = true;
  };

  environment.systemPackages = [ ]; # optional for now

  system.stateVersion = "25.11";
}
