{ pkgs, ... }:

{
  xdg.configFile = {
    "niri/config.kdl".source = ./config.kdl;
    "niri/binds.kdl".source = ./binds.kdl;
    "niri/settings.kdl".source = ./settings.kdl;
    "niri/ux.kdl".source = ./ux.kdl;
  };

  services.udiskie.enable = true;

  home.packages = [
    pkgs.wl-clipboard # move this into a Desktop file when it makes sense

    (pkgs.writeShellApplication {
      name = "focus-or-spawn";

      runtimeInputs = [
        pkgs.jq
        pkgs.niri
      ];

      text = ''
        app_id=$1
        shift

        id=$(
          niri msg -j windows |
            jq -r --arg app "$app_id" \
              '[.[] | select(.app_id == $app)][0].id // empty'
        )

        if [ -n "$id" ]; then
          exec niri msg action focus-window --id "$id"
        else
          exec "$@"
        fi
      '';
    })
  ];
}
