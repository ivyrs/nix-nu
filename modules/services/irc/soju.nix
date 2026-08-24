{ config, ... }:

{
  services.soju = {
    enable = true;
    hostName = "bnc.ocelot-perch.ts.net";
    listen = [ "irc+insecure://127.0.0.1:6698" ];
  };

  systemd.services.tailscale-serve-bnc = {
    description = "Advertise Soju as the bnc Tailscale Service";

    after = [
      "tailscaled.service"
      "soju.service"
    ];
    wants = [ "tailscaled.service" ];
    wantedBy = [ "multi-user.target" ];
    partOf = [ "tailscaled.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = "2s";

      ExecStart = "${config.services.tailscale.package}/bin/tailscale serve --service=svc:bnc --tls-terminated-tcp=6698 tcp://127.0.0.1:6698";
      ExecStop = "${config.services.tailscale.package}/bin/tailscale serve --service=svc:bnc --tls-terminated-tcp=6698 off";
    };
  };
}
