{ config, pkgs, ... }:

{
  nix.settings = {
    extra-substituters = [
      "https://ivyturner.cachix.org"
      "https://noctalia.cachix.org"
    ];

    extra-trusted-public-keys = [
      "ivyturner.cachix.org-1:G+GeQA1oBRaM2FfsUJph4QH8bNlkpvEQmxt42YFO00o="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  # TODO fix auth tokens
  sops.secrets.cachix-auth-token-alder = { };

  systemd.services.cachix-watch-store = {
    description = "Push new /nix/store paths to the ivyturner Cachix cache";

    wantedBy = [
      "multi-user.target"
    ];

    after = [
      "network-online.target"
    ];

    wants = [
      "network-online.target"
    ];

    serviceConfig = {
      ExecStart = "${pkgs.cachix}/bin/cachix watch-store ivyturner";

      EnvironmentFile = config.sops.secrets.cachix-auth-token-alder.path;

      Restart = "on-failure";
      RestartSec = "30s";
    };
  };
}
