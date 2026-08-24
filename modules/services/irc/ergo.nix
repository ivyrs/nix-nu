{ config, lib, ... }:

{
  services.ergochat = {
    enable = true;

    settings = {
      network.name = "ocelot-perch.ts.net";

      server = {
        name = "irc.ocelot-perch.ts.net";
        listeners = lib.mkForce {
          "127.0.0.1:6667" = { };
        };
      };
    };
  };

  systemd.services.tailscale-serve-irc = {
    description = "Advertise Ergo as the irc Tailscale Service";

    after = [
      "tailscaled.service"
      "ergochat.service"
    ];
    wants = [ "tailscaled.service" ];
    wantedBy = [ "multi-user.target" ];
    partOf = [ "tailscaled.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = "2s";

      ExecStart = "${config.services.tailscale.package}/bin/tailscale serve --service=svc:irc --tls-terminated-tcp=6667 tcp://127.0.0.1:6667";
      ExecStop = "${config.services.tailscale.package}/bin/tailscale serve --service=svc:irc --tls-terminated-tcp=6667 off";
    };
  };
}
