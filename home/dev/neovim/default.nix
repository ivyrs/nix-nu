{
  imports = [
    ./core.nix
  ];

  programs.nvf.settings = {
    imports = [ ./config/languages.nix ];
  };
}
