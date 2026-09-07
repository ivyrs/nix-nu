{ pkgs, ... }:
{
  home.packages = with pkgs; [
    bitwarden-desktop
    bitwarden-cli
    rbw
    pinentry-gnome3
  ];

  xdg.configFile."net.imput.helium/NativeMessagingHosts/com.8bit.bitwarden.json".text =
    builtins.toJSON {
      name = "com.8bit.bitwarden";
      description = "Bitwarden desktop <-> browser bridge";
      path = "${pkgs.bitwarden-desktop}/libexec/desktop_proxy";
      type = "stdio";
      allowed_origins = [
        "chrome-extension://nngceckbapebfimnlniiiahkandclblb/"
      ];
    };

  home.sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/rbw/ssh-agent-socket";
}
