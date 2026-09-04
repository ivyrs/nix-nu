{ pkgs, ... }:

let
  mkScript =
    name: runtimeInputs:
    pkgs.writeShellApplication {
      inherit name runtimeInputs;
      text = builtins.readFile ./${name};
    };

  cnote = mkScript "cnote" (
    with pkgs;
    [
      gum
      findutils
      coreutils
    ]
  );

  jrnl = mkScript "jrnl" (
    with pkgs;
    [
      coreutils
    ]
  );
in
{
  home.packages = [
    cnote
    jrnl
  ];
}
