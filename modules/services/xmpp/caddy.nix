{ lib, ... }:

# XMPP-related Caddy reverse proxies for HTTP file upload and other HTTP endpoints

let
  domain = "houseplants.cloud";

  accessLogFormat = ''
    output stdout
    format json
  '';
in
{
  services.caddy.virtualHosts = {
    # HTTP file upload endpoint
    "upload.${domain}" = {
      logFormat = accessLogFormat;
      extraConfig = ''
        encode zstd gzip
        header Access-Control-Allow-Origin "*"
        header Access-Control-Allow-Methods "GET, PUT, OPTIONS"
        header Access-Control-Allow-Headers "Content-Type"
        reverse_proxy localhost:5280 {
          header_up Host "upload.${domain}"
        }
      '';
    };

    # Push notifications endpoint
    "push.${domain}" = {
      logFormat = accessLogFormat;
      extraConfig = ''
        reverse_proxy localhost:5280 {
          header_up Host "push.${domain}"
        }
      '';
    };

    # XMPP server discovery (optional, for web-based clients)
    "xmpp.${domain}" = {
      logFormat = accessLogFormat;
      extraConfig = ''
        # BOSH/WebSocket endpoints
        reverse_proxy localhost:5280
      '';
    };
  };
}
