{ pkgs, lib, ... }:
let
  domain = "houseplants.cloud";
  tailnet = "ocelot-perch.ts.net";

  # NixOS' caddy module defaults each vhost's own `logFormat` to a
  # per-domain file under /var/log/caddy (no rotation). Override it
  # uniformly instead, since journald is the only log sink we want.
  #
  # `output journal` needs the caddy.logging.writers.journal module,
  # which nixpkgs' caddy build doesn't include (no libsystemd/CGO link).
  # Plain stdout is captured into journald by systemd anyway, so this
  # gets the same result without the missing module.
  accessLogFormat = ''
    output stdout
    format json
  '';

  staticSite = pkgs.runCommand "houseplants-static-site" { } ''
    mkdir -p $out
    cp ${./houseplants-index.html} $out/index.html
  '';
in
{
  services.caddy = {
    enable = true;
    email = "ivy@ivy.rs";

    logFormat = accessLogFormat;

    virtualHosts."${domain}" = {
      logFormat = accessLogFormat;
      extraConfig = ''
        root * ${staticSite}
        file_server
      '';
    };

    virtualHosts."fedi.ivy.rs" = {
      logFormat = accessLogFormat;
      extraConfig = ''
        encode zstd gzip
        reverse_proxy elm.${tailnet}:9400 {
          flush_interval -1
        }
      '';
    };

    virtualHosts."stardust.dog" = {
      logFormat = accessLogFormat;
      extraConfig = ''
        redir * https://discord.gg/8ev6mm4yPm
      '';
    };

    virtualHosts."nc.${domain}" = {
      serverAliases = [ "cloud.${domain}" ];
      logFormat = accessLogFormat;
      extraConfig = ''
        header Strict-Transport-Security "max-age=15552000"
        reverse_proxy elm.${tailnet}:80
      '';
    };

    virtualHosts."git.${domain}" = {
      logFormat = accessLogFormat;
      extraConfig = ''
        reverse_proxy elm.${tailnet}:3001
      '';
    };

    virtualHosts."rss.${domain}" = {
      logFormat = accessLogFormat;
      extraConfig = ''
        reverse_proxy elm.${tailnet}:3000
      '';
    };

    virtualHosts."id.${domain}" = {
      logFormat = accessLogFormat;
      extraConfig = ''
        reverse_proxy elm.${tailnet}:1411
      '';
    };

    virtualHosts."vault.${domain}" = {
      logFormat = accessLogFormat;
      extraConfig = ''
        reverse_proxy elm.${tailnet}:8222
      '';
    };

    virtualHosts."live.${domain}" = {
      logFormat = accessLogFormat;
      extraConfig = ''
        encode zstd gzip
        reverse_proxy elm.${tailnet}:8081
      '';
    };
  };

  # nixpkgs' caddy module already sandboxes reasonably
  # tighten further since this is the one host exposed to the internet.
  systemd.services.caddy.serviceConfig = {
    ProtectSystem = lib.mkForce "strict";
    ProtectKernelTunables = true;
    ProtectKernelModules = true;
    ProtectKernelLogs = true;
    ProtectControlGroups = true;
    ProtectClock = true;
    ProtectHostname = true;
    PrivateDevices = true;
    RestrictNamespaces = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    LockPersonality = true;
    MemoryDenyWriteExecute = true;
    RemoveIPC = true;
    SystemCallFilter = [
      "@system-service"
      "~@privileged"
      "~@resources"
    ];
    SystemCallArchitectures = "native";
    RestrictAddressFamilies = [
      "AF_UNIX"
      "AF_INET"
      "AF_INET6"
    ];
    UMask = "0077";
  };
}
