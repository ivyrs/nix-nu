{ pkgs, ... }:
{
  programs.anki = {
    enable = true;
    language = "en_GB";

    addons = with pkgs.ankiAddons; [
      anki-connect
    ];
  };
}
