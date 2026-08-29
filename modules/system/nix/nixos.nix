{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.nix-index-database.nixosModules.nix-index
  ];

  nixpkgs.overlays = [
    (_final: prev: {
      inherit (prev.lixPackageSets.stable)
        nixpkgs-review
        nix-eval-jobs
        nix-fast-build
        colmena
        ;
    })
  ];

  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];

  programs.nix-index.enable = false;
  programs.nix-index-database.comma.enable = true;

  programs.nh = {
    enable = true;

    flake = "/home/ivy/nix-nu";

    clean = {
      enable = true;
      dates = "Sun 03:00";
    };
  };
}
