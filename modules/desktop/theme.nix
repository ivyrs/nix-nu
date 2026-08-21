{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    adw-gtk3
    nwg-look
    qt6Packages.qt6ct
  ];

  qt = {
    enable = true;
    platformTheme = null;
  };

  environment.sessionVariables.QT_QPA_PLATFORMTHEME = "qt6ct";
}
