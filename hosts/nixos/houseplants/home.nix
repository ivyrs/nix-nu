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
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;
}
