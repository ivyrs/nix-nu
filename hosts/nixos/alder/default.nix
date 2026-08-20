{ ... }:

{
  imports = [
    ./hardware.nix

    ../../../modules/hardware/apple-silicon.nix

    ../../../modules/system/nix/default.nix
    ../../../modules/system/nix/nixos.nix
    ../../../modules/system/nix/cachix.nix
    
    ../../../modules/users/ivy.nix

    ../../../modules/services/ssh.nix
    ../../../modules/services/sops.nix
    ../../../modules/services/tailscale.nix
  ];

  networking = {
    hostName = "alder";

    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };

    firewall.enable = true;
  };

  environment.systemPackages = []; # optional for now

  # Keep the version Alder was originally installed with.
  system.stateVersion = "25.11";
}
