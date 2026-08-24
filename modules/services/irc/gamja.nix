{ config, pkgs, ... }:

{
  services.soju.listen = [
    "http+insecure://127.0.0.1:6699"
  ];

  systemd.services.tailscale-serve-bnc-web = {
    description = "Advertise Gamja and Soju's WebSocket under the bnc Tailscale Service";

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

      ExecStart = pkgs.writeShellScript "tailscale-serve-bnc-web-start" ''
        set -e
        ${config.services.tailscale.package}/bin/tailscale serve --service=svc:bnc --https=443 ${pkgs.gamja}
        ${config.services.tailscale.package}/bin/tailscale serve --service=svc:bnc --https=443 --set-path=/socket http://127.0.0.1:6699/socket
      '';
      ExecStop = "${config.services.tailscale.package}/bin/tailscale serve --service=svc:bnc --https=443 off";
    };
  };
}
