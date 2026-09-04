{
  programs.vesktop = {
    enable = true;
    settings = {
      # The Asahi GPU driver crashes Vesktop's GPU process (and has taken
      # down the whole machine) under Chromium's hardware-accelerated
      # compositing/video path. Software rendering is slower but stable.
      hardwareAcceleration = false;
    };
  };
}
