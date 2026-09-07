{
  config,
  lib,
  metadata,
  pkgs,
  ...
}:

{
  imports = [
    ./caddy.nix
  ];
  services.prosody = {
    enable = true;
    package = pkgs.prosody;

    # Admin JID
    admins = [ metadata.user.emails.primary ];

    # Disable public registration
    allowRegistration = false;

    # Require encryption
    c2sRequireEncryption = true;
    s2sRequireEncryption = true;
    s2sSecureAuth = true;

    # SSL/TLS configuration - certificates managed by ACME/Caddy
    ssl = {
      key = "/var/lib/acme/xmpp.${metadata.domains.services}/key.pem";
      cert = "/var/lib/acme/xmpp.${metadata.domains.services}/fullchain.pem";
    };

    # HTTP file upload configuration
    httpFileShare = {
      enable = true;
      domain = "upload.${metadata.domains.services}";
      http_external_url = "https://upload.${metadata.domains.services}";
      uploadFileSizeLimit = 10485760; # 10 MB
      uploadExpireAfter = "7d"; # Files expire after 7 days
    };

    # Core modules
    modules = {
      # Essential
      roster = true;
      saslauth = true;
      tls = true;
      dialback = true;
      disco = true;
      carbons = true;
      pep = true;
      private = true;
      blocklist = true;
      vcard_legacy = true;

      # Multi-device support
      smacks = true; # Stream Management (XEP-0198)
      csi = true; # Client State Indication

      # Message Archive Management
      mam = true;

      # Modern features
      bookmarks = true;
      ping = true;
      time = true;
      uptime = true;
      version = true;
      admin_adhoc = true;
      announce = true;
      server_contact_info = true;

      # Disable unwanted features
      register = false; # No public registration
      motd = false;
      welcome = false;
    };

    # VirtualHosts
    virtualHosts = {
      ${metadata.domains.personal} = {
        enabled = true;
        domain = metadata.domains.personal;
        ssl = {
          key = "/var/lib/acme/${metadata.domains.personal}/key.pem";
          cert = "/var/lib/acme/${metadata.domains.personal}/fullchain.pem";
        };
      };

      ${metadata.domains.services} = {
        enabled = true;
        domain = metadata.domains.services;
        ssl = {
          key = "/var/lib/acme/${metadata.domains.services}/key.pem";
          cert = "/var/lib/acme/${metadata.domains.services}/fullchain.pem";
        };
      };
    };

    # Multi-user chat configuration
    muc = [
      {
        domain = "conference.${metadata.domains.services}";
      }
    ];

    # Additional configuration for modern XMPP features
    extraConfig = ''
      -- Archive settings
      archive_expires_after = "1y"

      -- Better logging for troubleshooting
      log = {
        info = "*syslog";
        error = "*syslog";
      }

      -- OMEMO support (via PEP/PubSub)
      -- Already enabled via pep module

      -- Contact addresses (XEP-0157)
      contact_info = {
        abuse = { "mailto:webmistress@${metadata.domains.services}" };
        admin = { "mailto:webmistress@${metadata.domains.services}" };
      }

      -- Consider proxy for older clients (optional)
      -- Component "proxy.${metadata.domains.services}" "proxy65"
      --   proxy65_address = "xmpp.${metadata.domains.services}"
      --   proxy65_ports = { 5000 }
    '';
  };

  # Firewall configuration for XMPP
  networking.firewall = {
    allowedTCPPorts = [
      5222 # client-to-server
      5269 # server-to-server
      5280 # HTTP upload/BOSH/WebSocket
    ];
  };

  # Ensure prosody user can read certificates
  users.users.prosody.extraGroups = [ "acme" ];

  # Systemd service dependencies
  systemd.services.prosody = {
    after = [ "acme-finished.target" ];
    wants = [ "acme-finished.target" ];
  };
}
