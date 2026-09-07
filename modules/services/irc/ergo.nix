{
  config,
  lib,
  metadata,
  ...
}:

{
  services.ergochat = {
    enable = true;

    settings = {
      network.name = metadata.tailnet.domain;

      server = {
        name = "irc.${metadata.tailnet.domain}";
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
