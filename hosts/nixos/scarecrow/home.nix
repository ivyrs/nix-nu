{
  imports = [
    ../../../home/shell
    ../../../home/git
    ../../../home/neovim/core.nix
    ../../../home/tmux
  ];

  home = {
    username = "ivy";
    homeDirectory = "/home/ivy";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
