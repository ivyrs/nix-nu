{ inputs, metadata, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    extraSpecialArgs = {
      inherit inputs metadata;
    };

    backupFileExtension = "hm-backup";
  };
}
