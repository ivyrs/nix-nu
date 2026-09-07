{ metadata, ... }:

{
  programs.senpai = {
    enable = true;
    config = {
      address = "bnc.${metadata.tailnet.domain}:6698";
      nickname = metadata.user.username;
      username = metadata.user.username;
      password-cmd = [
        "cat"
        "/run/secrets/ivy-soju-pass"
      ];
    };
  };
}
