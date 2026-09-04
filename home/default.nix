{ ... }:

{
  home = {
    username = "ivy";
    homeDirectory = "/home/ivy";
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;

  imports = [
    ./chat
    ./desktop
    ./dev
    ./files
    ./media
    ./pim
    ./security
    ./shell
    ./shell/tmux
  ];
}
