{ inputs, ... }:

{
  imports = [
    inputs.nvf.homeManagerModules.default
  ];

  programs.nvf = {
    enable = true;

    settings = {
      imports = [
        ./config/core.nix
        ./config/languages.nix
      ];
    };
  };
}
