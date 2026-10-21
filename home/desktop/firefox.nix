{
  lib,
  pkgs,
  config,
  ...
}:

{
  programs.firefox = {
    enable = true;
    configPath = lib.mkIf pkgs.stdenv.hostPlatform.isLinux "${config.xdg.configHome}/mozilla/firefox";
  };
}
