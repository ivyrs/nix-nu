{ inputs, pkgs, ... }:
{
  # home-manager imports
  imports = [ inputs.otter-launcher.homeModules.default ];

  programs.otter-launcher = {
    enable = true;
    settingsExtra = builtins.readFile ./otter-config.toml;
  };

  home.packages = [
    pkgs.wiremix
    pkgs.wdisplays
    (pkgs.callPackage ../../pkgs/lazytailscale.nix { })
    (pkgs.writeShellApplication {
      name = "tui";
      runtimeInputs = [
        pkgs.ghostty
        pkgs.util-linux
      ];
      text = ''
        setsid -f ghostty --gtk-single-instance=false --class=rs.ivy.tui -e "$@" >/dev/null 2>&1
      '';
    })
  ];
}
