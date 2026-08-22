{ config, ... }:

{
  services.miniflux = {
    enable = true;

    config = {
      LISTEN_ADDR = "0.0.0.0:3000";
      BASE_URL = "https://rss.houseplants.cloud";

      OAUTH2_PROVIDER = "oidc";
      OAUTH2_CLIENT_ID = "046ab3a0-0b0a-4eb8-92d9-4feb1b0e6fb5";
      OAUTH2_OIDC_DISCOVERY_ENDPOINT = "https://id.houseplants.cloud";
      OAUTH2_REDIRECT_URL = "https://rss.houseplants.cloud/oauth2/oidc/callback";
      OAUTH2_USER_CREATION = 1;

      DISABLE_LOCAL_AUTH = 1;
    };

    adminCredentialsFile = config.sops.secrets.miniflux-admin-credentials.path;
  };

  sops.secrets.miniflux-admin-credentials = { };
}
