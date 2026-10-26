{ metadata, pkgs, ... }:
{
  xdg.configFile."umbriel/config.toml".source = pkgs.writeText "umbriel-config.toml" (
    builtins.replaceStrings [ "@home@" ] [ metadata.user.homeDirectory ] (
      builtins.readFile ./config.toml
    )
  );
}
