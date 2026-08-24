{ config, ... }:

{
  services.glance = {
    enable = true;

    settings = {
      server = {
        host = "127.0.0.1";
        port = 8080;
        assets-path = ./assets;
      };

      theme = {
        background-color = "240 21.1 14.9";
        primary-color = "232 97.4 85.1";
        contrast-multiplier = 1.1;
        custom-css-file = "/assets/user.css";
      };

      pages = [
        {
          name = "Home";
          hide-desktop-navigation = true;

          columns = [
            {
              size = "full";

              widgets = [
                (import ./_clock-weather.nix {
                  cityFile = config.sops.secrets.glance-city.path;
                })
                (import ./_monitor-sites.nix)
                (import ./_server-stats.nix {
                  tokenFile = config.sops.secrets.glance-agent-token.path;
                })
                (import ./_bookmarks.nix)
              ];
            }
          ];
        }
      ];
    };
  };

  sops.secrets.glance-city = { };
  sops.secrets.glance-agent-token = { };

  systemd.services.tailscale-serve-dash = {
    description = "Advertise Glance as the dash Tailscale Service";

    after = [
      "tailscaled.service"
      "glance.service"
    ];
    wants = [ "tailscaled.service" ];
    wantedBy = [ "multi-user.target" ];
    partOf = [ "tailscaled.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = "2s";

      ExecStart = "${config.services.tailscale.package}/bin/tailscale serve --service=svc:dash --https=443 8080";
      ExecStop = "${config.services.tailscale.package}/bin/tailscale serve --service=svc:dash --https=443 off";
    };
  };
}
