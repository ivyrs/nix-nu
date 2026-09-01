{ pkgs, ... }:

let
  cnote = pkgs.writeShellApplication {
    name = "cnote";

    runtimeInputs = with pkgs; [
      gum
      findutils
      coreutils
    ];

    text = builtins.readFile ./cnote;
  };
  jrnl = pkgs.writeShellApplication {
    name = "jrnl";
    runtimeInputs = with pkgs; [
      coreutils
    ];
    text = builtins.readFile ./jrnl;
  };
in {
  home.packages = [
    cnote
    jrnl
  ];
}
