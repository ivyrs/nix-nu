{ inputs, ... }:
{
  imports = [ inputs.noctalia.homeModules.default ];

  programs.noctalia = {
    enable = true;
    settings = ./noctalia.toml;
    systemd.enable = true;
  };
}
