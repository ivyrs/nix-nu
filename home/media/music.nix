{ pkgs, ... }: {
  home.packages = with pkgs; [
    ncspot
    playerctl
    feishin
  ];
}
