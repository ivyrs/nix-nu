{ inputs, pkgs, ... }:

let
  packages = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;

    config.allowUnfree = true;
  };
in
{
  home.packages = with packages; [
    zapp # keyboard flasher
    openlogi # options+ replacement for mouse
  ];
}
