{ config, inputs, ... }:
{
  imports = [
    ./server.nix
    inputs.disko.nixosModules.disko
  ];

  networking = {
    networkmanager.enable = false;
    firewall.allowedTCPPorts = [
      80
      443
    ];
  };

  # Public edge: SSH must not be reachable off the tailnet.
  services.openssh.openFirewall = false;
  services.tailscale.useRoutingFeatures = "server";

  sops.secrets.desec-token = {
    owner = "acme";
    group = "acme";
    mode = "0440";
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "ivy@ivy.rs";
      dnsProvider = "desec";
      environmentFile = config.sops.secrets.desec-token.path;
    };
  };
}
