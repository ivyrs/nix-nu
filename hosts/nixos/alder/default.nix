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
    ../../../modules/desktop/theme.nix

    ../../../modules/system/fonts.nix
    ../../../modules/system/locale.nix

    ../../../modules/system/home-manager.nix
  ];

  home-manager.users.ivy.imports = [
    ./home.nix
    ../../../home
  ];

  networking = {
    hostName = "alder";

    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };

    firewall.enable = true;
  };

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  environment.systemPackages = [ ]; # optional for now

  system.stateVersion = "25.11";

  sops.defaultSopsFile = ../../../secrets/alder.yaml;
  sops.secrets = {
    aerc-fastmail-password.owner = "ivy";
    gmail-app-password.owner = "ivy";
    ivy-nextcloud-app-password.owner = "ivy";
    icloud-username.owner = "ivy";
    icloud-password.owner = "ivy";
  };
}
