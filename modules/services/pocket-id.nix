{ config, ... }:
{
  services.pocket-id = {
    enable = true;
    # TODO: make this come from unstable
    # package = null;

    settings = {
      APP_URL = "https://id.houseplants.cloud";
      TRUST_PROXY = true;
    };

    credentials.ENCRYPTION_KEY = config.sops.secrets.pocket-id-encryption-key.path;
  };

  sops.secrets.pocket-id-encryption-key = { };
}
