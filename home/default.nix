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

  ./ghostty.nix
  ./git.nix
  ./bitwarden.nix
  ./keepassxc.nix
  ./firefox.nix
  ./ai.nix
  ./gpg.nix

  ./pim

  ./media.nix
  # ./music.nix
  ./zathura.nix
];
}
