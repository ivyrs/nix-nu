{ pkgs, ... }:

{
  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    pinentry.package =
      if pkgs.stdenv.hostPlatform.isDarwin then pkgs.pinentry-curses else pkgs.pinentry-gnome3;
  };
}
