{
  pkgs,
  inputs,
  ...
}:

{
  # TODO: decide which one i like

  home.packages = with pkgs; [
    claude-code
    opencode
    pi-coding-agent
    codex
    inputs.oh-my-pi.packages.${stdenv.hostPlatform.system}.default
  ];
}
