{ pkgs, ... }:

{
  imports = [ ./music.nix ];

  home.packages = with pkgs; [
    mpv
    imv
    aseprite
  ];
}
