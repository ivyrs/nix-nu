{ lib, pkgs, ... }:

{
  programs.tmux = {
    enable = true;

    extraConfig = lib.mkMerge [
      (builtins.readFile ./tmux.conf)

      ''
        # Remote clients use tmux's OSC52; local clients use the native clipboard.
        set -as terminal-features ',*:clipboard'
        bind -T copy-mode-vi y if-shell -F '#{||:#{SSH_CONNECTION},#{SSH_TTY}}' 'send-keys -X copy-selection-and-cancel' 'send-keys -X copy-pipe-and-cancel "${
          if pkgs.stdenv.hostPlatform.isDarwin then "/usr/bin/pbcopy" else "${pkgs.wl-clipboard}/bin/wl-copy"
        }"'
        bind -T copy-mode-vi MouseDragEnd1Pane if-shell -F '#{||:#{SSH_CONNECTION},#{SSH_TTY}}' 'send-keys -X copy-selection-and-cancel' 'send-keys -X copy-pipe-and-cancel "${
          if pkgs.stdenv.hostPlatform.isDarwin then "/usr/bin/pbcopy" else "${pkgs.wl-clipboard}/bin/wl-copy"
        }"'
      ''
    ];
  };
}
