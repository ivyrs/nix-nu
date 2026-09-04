{ inputs, ... }:
{
  imports = [
    ../../../home/shell
    ../../../home/dev/git
    ../../../home/shell/tmux
    ../../../home/dev/neovim/core.nix
  ];

  home = {
    username = "ivy";
    homeDirectory = "/home/ivy";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
