{ metadata, ... }:

{
  imports = [
    ../shell
    ../dev/git
    ../dev/neovim/core.nix
    ../shell/tmux
  ];

  home = {
    username = metadata.user.username;
    homeDirectory = metadata.user.homeDirectory;
  };

  programs.home-manager.enable = true;
}
