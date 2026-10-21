{ pkgs, ... }: {
  home.packages = [
    pkgs.sioyek
    pkgs.typst
    pkgs.pandoc
    pkgs.imagemagick # for obsidian typst pdf plugin
  ];
}
