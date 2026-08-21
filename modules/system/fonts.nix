# modules/system/fonts.nix
{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    ibm-plex
    aporetic
    nerd-fonts.symbols-only
  ];
}
