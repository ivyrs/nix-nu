{
  imports = [
    ../../../home/shell
    ../../../home/dev/git
    ../../../home/dev/neovim/core.nix
    ../../../home/shell/tmux
  ];

  home = {
    username = "ivy";
    homeDirectory = "/home/ivy";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
