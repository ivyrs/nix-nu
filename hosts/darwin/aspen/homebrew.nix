{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };

    brews = [ "mas" ];

    casks = [
      "anki"
      "tailscale-app"
      "keymapp"
      "karabiner-elements"
      "helium-browser"
      "raycast"
      "shottr"
    ];
  };
}
