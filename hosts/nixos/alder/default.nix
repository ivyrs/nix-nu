{
  config,
  metadata,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware.nix

    ../../../modules/hardware/apple-silicon.nix
    ../../../modules/hardware/peripherals.nix

    ../../../modules/system/nix
    ../../../modules/system/nix/nixos.nix
    ../../../modules/system/nix/cachix.nix
    ../../../modules/system/boot/blahaj.nix

    ../../../modules/users/ivy.nix

    ../../../modules/services/ssh.nix
    ../../../modules/services/sops.nix
    ../../../modules/services/tailscale.nix
    ../../../modules/services/ly.nix

    ../../../modules/desktop/niri.nix
    ../../../modules/desktop/umbriel.nix
    ../../../modules/desktop/portals.nix
    ../../../modules/desktop/audio.nix
    ../../../modules/desktop/theme.nix

    ../../../modules/system/fonts.nix
    ../../../modules/system/locale.nix

    ../../../modules/system/home-manager.nix
  ];

  home-manager.users.${metadata.user.username}.imports = [
    ./home.nix
    ../../../home
  ];

  networking = {
    hostName = metadata.hosts.alder.name;

    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };

    firewall.enable = true;
  };

  services.tailscale.extraSetFlags = [ "--operator=ivy" ];

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  zramSwap.enable = true;

  # lets us build the x86_64-linux installer ISO (hosts/nixos/installer)
  # locally under qemu emulation instead of needing a remote builder.
  boot.binfmt.emulatedSystems = [ "x86_64-linux" ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # video
      wayland
      libxkbcommon
      libdecor
      libGL
      vulkan-loader
      libX11
      libXext
      libXcursor
      libXrandr
      libXi
      libXinerama
      # audio
      alsa-lib
      libpulseaudio
      pipewire
    ];
  };

  hardware.graphics.enable = true; # provides /run/opengl-driver (Mesa)

  environment.systemPackages = [ ];
  system.stateVersion = "25.11";

  users.users.${metadata.user.username}.hashedPasswordFile =
    config.sops.secrets.ivy-password-hash-alder.path;

  sops.defaultSopsFile = ../../../secrets/alder.yaml;
  sops.secrets = {
    ivy-password-hash-alder.neededForUsers = true;
    aerc-fastmail-password.owner = metadata.user.username;
    gmail-app-password.owner = metadata.user.username;
    ivy-nextcloud-app-password.owner = metadata.user.username;
    icloud-username.owner = metadata.user.username;
    icloud-password.owner = metadata.user.username;
    ivy-soju-pass.owner = metadata.user.username;
  };
}
