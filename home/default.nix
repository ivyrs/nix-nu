{ ... }:

{
  home = {
    username = "ivy";
    homeDirectory = "/home/ivy";
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;

  imports = [
    ./shell
    ./noctalia
    ./niri
    ./neovim
    ./tmux
    ./files
    ./git
    ./pim
    ./media
    
    ./media/music.nix
    ./ghostty.nix
    ./bitwarden.nix
    ./firefox.nix
    ./ai.nix
    ./gpg.nix
    ./files/syncthing.nix
    ./files/zathura.nix
  ];
}
