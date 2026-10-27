{
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  image.baseName = lib.mkForce "ivy-nixos-installer";

  # the whole flake, baked into the live image, so there's no need for
  # network access just to get started on a fresh machine.
  environment.etc."nixos-flake".source = lib.cleanSourceWith {
    src = ../../..;
    filter =
      name: _type:
      let
        base = baseNameOf (toString name);
      in
      !(builtins.elem base [
        ".git"
        ".direnv"
        "result"
      ]);
  };

  environment.systemPackages = with pkgs; [
    git
    just
  ];

  networking.networkmanager.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
