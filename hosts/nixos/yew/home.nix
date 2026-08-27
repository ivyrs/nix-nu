{ inputs, ... }:
{
  imports = [
    ../../../home/shell
    ../../../home/git
    ../../../home/tmux
    ../../../home/neovim/core.nix
  ];

  home = {
    username = "ivy";
    homeDirectory = "/home/ivy";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
