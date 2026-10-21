{ lib, pkgs, ... }:

{
  imports = [ ./music.nix ];

  home.packages =
    (with pkgs; [
      mpv
      aseprite
    ])
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.imv ];
}
