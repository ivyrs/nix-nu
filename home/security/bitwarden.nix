{ pkgs, ... }:
{
  home.packages = with pkgs; [
    bitwarden-desktop
    bitwarden-cli
    rbw
    pinentry-gnome3
  ];

  home.sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/rbw/ssh-agent-socket";
}
