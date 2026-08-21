{ ... }:

{
  home = {
    username = "ivy";
    homeDirectory = "/home/ivy";
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;

  imports = [
    ./ghostty.nix
    ./git.nix
    ./shell
    ./noctalia.nix
  ];
}
