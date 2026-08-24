{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.forgejo = {
    enable = true;
    package = pkgs.forgejo;

    database.type = "postgres";
    lfs.enable = true;

    settings = {
      server = {
        DOMAIN = "git.houseplants.cloud";
        ROOT_URL = "https://git.houseplants.cloud/";
        HTTP_PORT = 3001;

        SSH_DOMAIN = "elm.ocelot-perch.ts.net";
        SSH_PORT = 2222;
        START_SSH_SERVER = true;
      };

      service = {
        DISABLE_REGISTRATION = true;
        ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
        ENABLE_INTERNAL_SIGNIN = false;
        REGISTER_EMAIL_CONFIRM = false;
        ENABLE_NOTIFY_MAIL = false;
        DEFAULT_ALLOW_CREATE_ORGANIZATION = true;
        DEFAULT_ENABLE_TIMETRACKING = true;
        ENABLE_CAPTCHA = false;
      };

      security = {
        REVERSE_PROXY_LIMIT = 1;
        REVERSE_PROXY_TRUSTED_PROXIES = "100.64.20.1";
      };

      oauth2_client = {
        ENABLE_AUTO_REGISTRATION = true;
        ACCOUNT_LINKING = "auto";
        OPENID_CONNECT_SCOPES = "email profile";
        UPDATE_AVATAR = true;
      };

      mailer.ENABLED = false;

      ui = {
        THEMES = "catppuccin-red-auto,catppuccin-mocha-red,catppuccin-latte-red";
        DEFAULT_THEME = "catppuccin-red-auto";
      };

      other = {
        SHOW_FOOTER_VERSION = false;
        SHOW_FOOTER_POWERED_BY = false;
        SHOW_FOOTER_TEMPLATE_LOAD_TIME = false;
      };

      "repository.pull-request".DEFAULT_MERGE_STYLE = "merge";
      "repository.signing".DEFAULT_TRUST_MODEL = "committer";
      "cron.update_checker".ENABLED = true;
    };

    # Keep these values stable so existing sessions, API tokens, and LFS
    # authentication remain valid across the migration.
    secrets = {
      security.INTERNAL_TOKEN = lib.mkForce config.sops.secrets.forgejo-internal-token.path;
      oauth2.JWT_SECRET = lib.mkForce config.sops.secrets.forgejo-oauth2-jwt-secret.path;
      server.LFS_JWT_SECRET = lib.mkForce config.sops.secrets.forgejo-lfs-jwt-secret.path;
    };
  };

  sops.secrets.forgejo-internal-token.owner = "forgejo";
  sops.secrets.forgejo-oauth2-jwt-secret.owner = "forgejo";
  sops.secrets.forgejo-lfs-jwt-secret.owner = "forgejo";

  # forgejo-secrets runs in a private mount namespace and otherwise cannot
  # see the sops-nix generation directories.
  systemd.services.forgejo-secrets.serviceConfig.BindReadOnlyPaths = [
    "/run/secrets.d"
    "/run/secrets"
  ];
}
