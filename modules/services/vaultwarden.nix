{ config, ... }:

{
  services.vaultwarden = {
    enable = true;
    dbBackend = "sqlite";

    config = {
      DOMAIN = "https://vault.houseplants.cloud";
      SIGNUPS_ALLOWED = false;
      ROCKET_ADDRESS = "0.0.0.0";
      ROCKET_PORT = 8222;

      SSO_ENABLED = true;
      SSO_AUTHORITY = "https://id.houseplants.cloud";
      SSO_CLIENT_ID = "91751e42-c596-4ef1-ba94-782e52fed1bc";
      SSO_PKCE = true;

      SMTP_HOST = "smtp.fastmail.com";
      SMTP_SECURITY = "starttls";
      SMTP_PORT = 587;
      SMTP_USERNAME = "ivy@ivy.rs";
      SMTP_FROM = "vault@houseplants.cloud";
      SMTP_FROM_NAME = "Vaultwarden";
    };

    environmentFile = config.sops.secrets.vaultwarden-env.path;
  };

  sops.secrets.vaultwarden-env = { };
}
