{ lib, ... }:

{
  programs.tmux = {
    enable = true;

    extraConfig = lib.mkMerge [
      (builtins.readFile ./tmux.conf)

      # Static fallback; Noctalia-aware config can override this later.
      (lib.mkDefault "")
    ];
  };
}
