{ config, pkgs, ... }:

{
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud34;
    hostName = "cloud.houseplants.cloud";

    database.createLocally = true;

    config = {
      dbtype = "pgsql";
      adminuser = "ivy";
      adminpassFile = config.sops.secrets.nextcloud-admin-password.path;
    };

    extraApps = {
      inherit (config.services.nextcloud.package.packages.apps) user_oidc;
    };
    appstoreEnable = true;

    settings = {
      maintenance_window_start = 1;
      default_phone_region = "GB";

      trusted_domains = [
        "nc.houseplants.cloud"
        "elm.ocelot-perch.ts.net"
      ];
      trusted_proxies = [ "100.64.20.1" ];

      mail_smtpmode = "smtp";
      mail_smtpauth = true;
      mail_smtphost = "smtp.fastmail.com";
      mail_smtpport = 587;
      mail_smtpname = "ivy@ivy.rs";
      mail_from_address = "cloud";
      mail_domain = "houseplants.cloud";
    };

    secrets.mail_smtppassword = config.sops.secrets.nextcloud-smtp-password.path;
    phpOptions."opcache.interned_strings_buffer" = "16";
  };

  sops.secrets.nextcloud-admin-password.owner = "nextcloud";
  sops.secrets.nextcloud-oidc-client-secret.owner = "nextcloud";
  sops.secrets.nextcloud-smtp-password.owner = "nextcloud";
  sops.secrets.nextcloud-harp-shared-key-env = { };

  systemd.services.nextcloud-oidc-provider = {
    description = "Register houseplantsID as a Nextcloud OIDC provider";
    after = [ "nextcloud-setup.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      User = "nextcloud";
      LoadCredential = "mail_smtppassword:${config.sops.secrets.nextcloud-smtp-password.path}";

      ExecStart = pkgs.writeShellScript "nextcloud-oidc-provider-setup" ''
        ${config.services.nextcloud.occ}/bin/nextcloud-occ user_oidc:provider houseplants \
          --clientid="f6af92ea-3466-4a98-bd68-528446898f60" \
          --clientsecret-file="${config.sops.secrets.nextcloud-oidc-client-secret.path}" \
          --discoveryuri="https://id.houseplants.cloud/.well-known/openid-configuration" \
          --scope="openid email profile" \
          --unique-uid=0 \
          --mapping-uid=preferred_username
      '';
    };
  };

  systemd.services.nextcloud-enable-totp = {
    description = "Enable Nextcloud's TOTP two-factor app";
    after = [ "nextcloud-setup.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      User = "nextcloud";
      LoadCredential = "mail_smtppassword:${config.sops.secrets.nextcloud-smtp-password.path}";
      ExecStart = "${config.services.nextcloud.occ}/bin/nextcloud-occ app:enable twofactor_totp";
    };
  };

  # Keep the OIDC provider as the default login while preserving Nextcloud's
  # `?direct=1` local-login recovery path.
  systemd.services.nextcloud-oidc-only-login = {
    description = "Make houseplants OIDC the default Nextcloud login";
    after = [
      "nextcloud-setup.service"
      "nextcloud-oidc-provider.service"
    ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      User = "nextcloud";
      LoadCredential = "mail_smtppassword:${config.sops.secrets.nextcloud-smtp-password.path}";

      # user_oidc expects this setting to be stored as a string, not an
      # integer or boolean.
      ExecStart = "${config.services.nextcloud.occ}/bin/nextcloud-occ config:app:set user_oidc allow_multiple_user_backends --value=0 --type=string";
    };
  };

  virtualisation.docker.enable = true;
  virtualisation.oci-containers.backend = "docker";

  virtualisation.oci-containers.containers.appapi-harp = {
    image = "ghcr.io/nextcloud/nextcloud-appapi-harp:release";
    autoStart = true;
    extraOptions = [ "--network=host" ];
    environmentFiles = [ config.sops.secrets.nextcloud-harp-shared-key-env.path ];
    environment.NC_INSTANCE_URL = "http://elm.ocelot-perch.ts.net";

    volumes = [
      "/var/run/docker.sock:/var/run/docker.sock"
      "/var/lib/appapi-harp/certs:/certs"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/appapi-harp/certs 0700 root root -"
  ];

  services.nginx.virtualHosts.${config.services.nextcloud.hostName}.locations."/exapps/" = {
    proxyPass = "http://127.0.0.1:8780";
    proxyWebsockets = true;

    extraConfig = ''
      proxy_set_header Host $host;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
    '';
  };

  systemd.services.nextcloud-appapi-harp-register = {
    description = "Register HaRP as Nextcloud's AppAPI deploy daemon";
    after = [
      "nextcloud-setup.service"
      "docker-appapi-harp.service"
    ];
    wants = [ "docker-appapi-harp.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      User = "nextcloud";

      LoadCredential = [
        "mail_smtppassword:${config.sops.secrets.nextcloud-smtp-password.path}"
        "harp_shared_key_env:${config.sops.secrets.nextcloud-harp-shared-key-env.path}"
      ];

      ExecStart = pkgs.writeShellScript "nextcloud-appapi-harp-register" ''
        HP_SHARED_KEY="$(cut -d= -f2- < "$CREDENTIALS_DIRECTORY/harp_shared_key_env")"
        ${config.services.nextcloud.occ}/bin/nextcloud-occ app:enable app_api
        ${config.services.nextcloud.occ}/bin/nextcloud-occ app_api:daemon:register harp1 "HaRP" docker-install http localhost:8780 "http://elm.ocelot-perch.ts.net" \
          --harp \
          --harp_frp_address "localhost:8782" \
          --harp_shared_key "$HP_SHARED_KEY" \
          --set-default
      '';
    };
  };

  # AppAPI invokes a bare `php`; use the same PHP package as Nextcloud's
  # configured FPM pool so extensions remain consistent.
  environment.systemPackages = [
    config.services.phpfpm.pools.nextcloud.phpPackage
  ];
}
