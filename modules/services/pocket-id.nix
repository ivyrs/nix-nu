{ config, metadata, ... }:
{
  services.pocket-id = {
    enable = true;
    # TODO: make this come from unstable
    # package = null;

    settings = {
      APP_URL = "https://id.${metadata.domains.services}";
      TRUST_PROXY = true;
    };

    credentials.ENCRYPTION_KEY = config.sops.secrets.pocket-id-encryption-key.path;
  };

  sops.secrets.pocket-id-encryption-key = { };
}
