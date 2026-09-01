{ ... }:
{
  imports = [
    ./hardware.nix
    ./disko.nix

    ../../../modules/roles/edge.nix
    ../../../modules/services/caddy
    ../../../modules/services/xmpp
  ];

  home-manager.users.ivy.imports = [
    ./home.nix
  ];

  networking = {
    hostName = "houseplants";
    useDHCP = true;

    # dhcpcd doesn't reliably populate /etc/resolv.conf before tailscaled
    # takes over DNS management, leaving tailscaled with no fallback
    # resolver for non-tailnet domains. Declare these statically instead.
    nameservers = [
      "185.12.64.2" # Hetzner recursive resolver
      "185.12.64.1"
    ];

    interfaces.enp1s0.ipv6.addresses = [
      {
        address = "2a01:4f8:c17:7da9::1";
        prefixLength = 64;
      }
    ];

    defaultGateway6 = {
      address = "fe80::1";
      interface = "enp1s0";
    };
  };

  system.stateVersion = "25.11";

  security.acme.certs = {
    "ivy.rs" = { };
    "houseplants.cloud" = {
      extraDomainNames = [ "conference.houseplants.cloud" ];
    };
    "xmpp.houseplants.cloud" = { };
  };
}
