{
  config,
  pkgs,
  inputs,
  ...
}:
let
  # Use latest ncspot with Spotify OAuth refresh token fix (PR #1861)
  # ncspot 1.4.0 fixes: "Stop discarding the Web API refresh token on every refresh"
  ncspot-latest = pkgs.ncspot.overrideAttrs (old: rec {
    version = "1.4.0";
    src = pkgs.fetchFromGitHub {
      owner = "hrkfdn";
      repo = "ncspot";
      rev = "v${version}";
      hash = "sha256-YJbdXLqFPYKnluHCR5svAGIkzbKH3xYPOnA2uQCK5q4=";
    };
    cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
      inherit src;
      hash = "sha256-4RRAFThnp06QFb3U4IjRTRc3B9muyajH592ZNWJrJZY=";
    };
  });
in
{
  home.packages = with pkgs; [
    ncspot-latest
    playerctl
    feishin
    inputs.musikcube.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  ## mpd 
  services.mpd = {
    enable = true;

  network = {
    listenAddress = "127.0.0.1";
    port = 6600;
  };

  musicDirectory = "${config.home.homeDirectory}/media/music"; 
  # TODO: make this overridable

  extraConfig = ''
    audio_output {
      type "pipewire"
      name "PipeWire"
    }
  '';
};
  ## rmpc
  programs.rmpc = {
    enable = true;
  };

  ## musikcube

  home.file.".config/musikcube/hotkeys.json" = {
    text = builtins.toJSON {
      key_up = "k";
      key_down = "j";
      key_left = "h";
      key_right = "l";
      key_page_up = "^B";
      key_page_down = "^F";
      key_home = "g";
      key_end = "G";

      # Keep the media controls reachable after j/k/l become navigation keys.
      playback_previous = "H";
      playback_next = "L";
      playback_volume_up = "+";
      playback_volume_down = "-";

      # ^F is used for page down above.
      browse_category_filter = "M-f";
    };
    force = true;
  };
}
