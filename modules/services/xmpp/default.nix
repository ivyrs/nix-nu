{
  config,
  lib,
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
    admins = [ "ivy@ivy.rs" ];

    # Disable public registration
    allowRegistration = false;

    # Require encryption
    c2sRequireEncryption = true;
    s2sRequireEncryption = true;
    s2sSecureAuth = true;

    # SSL/TLS configuration - certificates managed by ACME/Caddy
    ssl = {
      key = "/var/lib/acme/xmpp.houseplants.cloud/key.pem";
      cert = "/var/lib/acme/xmpp.houseplants.cloud/fullchain.pem";
    };

    # HTTP file upload configuration
    httpFileShare = {
      enable = true;
      domain = "upload.houseplants.cloud";
      http_external_url = "https://upload.houseplants.cloud";
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
      "ivy.rs" = {
        enabled = true;
        domain = "ivy.rs";
        ssl = {
          key = "/var/lib/acme/ivy.rs/key.pem";
          cert = "/var/lib/acme/ivy.rs/fullchain.pem";
        };
      };

      "houseplants.cloud" = {
        enabled = true;
        domain = "houseplants.cloud";
        ssl = {
          key = "/var/lib/acme/houseplants.cloud/key.pem";
          cert = "/var/lib/acme/houseplants.cloud/fullchain.pem";
        };
      };
    };

    # Multi-user chat configuration
    muc = [
      {
        domain = "conference.houseplants.cloud";
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
        abuse = { "mailto:webmistress@houseplants.cloud" };
        admin = { "mailto:webmistress@houseplants.cloud" };
      }

      -- Consider proxy for older clients (optional)
      -- Component "proxy.houseplants.cloud" "proxy65"
      --   proxy65_address = "xmpp.houseplants.cloud"
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
