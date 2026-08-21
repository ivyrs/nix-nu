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
  ./neovim
  ./tmux

  ./ghostty.nix
  ./git.nix
  ./bitwarden.nix
  ./keepassxc.nix
  ./firefox.nix
  ./ai.nix
  ./gpg.nix

  ./media.nix
  # ./music.nix
  ./zathura.nix
];
}
