{
  isDarwin ? false,
  lib,
  ...
}:

{
  imports = [
    ./yazi.nix
    ./syncthing.nix
    ./documents.nix
  ]
  ++ lib.optionals (!isDarwin) [
    ./anki.nix
    ./nextcloud-client.nix
    ./zathura.nix
  ];
}
