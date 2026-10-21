{ lib, pkgs, ... }:
{
  home.packages =
    (with pkgs; [
      bitwarden-desktop
      bitwarden-cli
      rbw
    ])
    ++ [ (if pkgs.stdenv.hostPlatform.isDarwin then pkgs.pinentry-curses else pkgs.pinentry-gnome3) ];

  xdg.configFile."net.imput.helium/NativeMessagingHosts/com.8bit.bitwarden.json" =
    lib.mkIf pkgs.stdenv.hostPlatform.isLinux
      {
        text = builtins.toJSON {
          name = "com.8bit.bitwarden";
          description = "Bitwarden desktop <-> browser bridge";
          path = "${pkgs.bitwarden-desktop}/libexec/desktop_proxy";
          type = "stdio";
          allowed_origins = [
            "chrome-extension://nngceckbapebfimnlniiiahkandclblb/"
          ];
        };
      };

  home.sessionVariablesExtra = ''
    # Keep forwarded agents over SSH; local sessions use the configured rbw agent.
    if { [ -z "''${SSH_CONNECTION:-}" ] && [ -z "''${SSH_TTY:-}" ]; } || [ -z "''${SSH_AUTH_SOCK:-}" ]; then
      export SSH_AUTH_SOCK=${
        if pkgs.stdenv.hostPlatform.isDarwin then
          ''"$(getconf DARWIN_USER_TEMP_DIR)rbw-$(id -u)/ssh-agent-socket"''
        else
          ''"$XDG_RUNTIME_DIR/rbw/ssh-agent-socket"''
      }
    fi
  '';
}
