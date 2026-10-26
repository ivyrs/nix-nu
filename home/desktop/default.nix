{
  isDarwin ? false,
  lib,
  ...
}:

{
  imports = [
    ./ai.nix
    ./firefox.nix
    ./ghostty.nix
    ./peripherals.nix
  ]
  ++ lib.optionals (!isDarwin) [
    ./niri
    ./noctalia
    ./umbriel
    ./helium.nix
    ./new-shell
  ];
}
