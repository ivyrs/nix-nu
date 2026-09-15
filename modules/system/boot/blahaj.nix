{ pkgs, ... }:
{
  boot.plymouth = {
    enable = true;
    theme = "blahaj";
    themePackages = with pkgs; [
      plymouth-blahaj-theme
    ];
  };
}
