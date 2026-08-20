{ pkgs, ... }:

{
  # nix for lesbians
  nix.package = pkgs.lixPackageSets.stable.lix;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  nix.optimise.automatic = true;
}
