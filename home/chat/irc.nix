{
  programs.senpai = {
    enable = true;
    config = {
      address = "bnc.ocelot-perch.ts.net:6698";
      nickname = "ivy";
      username = "ivy";
      password-cmd = [
        "cat"
        "/run/secrets/ivy-soju-pass"
      ];
    };
  };
}
