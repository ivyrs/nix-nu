{ pkgs, ... }:

{ # TODO: decide which one i like
  home.packages = with pkgs; [
    claude-code
    opencode
    pi-coding-agent
    codex
  ];
}
