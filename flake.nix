{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";

    # hardware support
    apple-silicon = {
      url = "github:nix-community/nixos-apple-silicon/release-2026-07-30";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # proprietary Apple firmware; kept outside the public repo
    asahi-firmware = {
      url = "path:/etc/nixos/asahi-firmware";
      flake = false;
    };

    sops = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, ... }: {
    nixosConfigurations.alder = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";

      specialArgs = {
        inherit inputs;
      };

      modules = [
        ./hosts/nixos/alder
      ];
    };
  };
}
