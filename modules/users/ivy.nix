{ pkgs, ... }:

{
  users.users.ivy = {
    isNormalUser = true;

    extraGroups = [
      "wheel"
      "networkmanager"
    ];

    shell = pkgs.zsh;

    # TODO: add alder's key back here
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICtFawaAWSklr1GGYiBZzGr/ydKSSOatBfGfY72eqKGZ ivy@aspen"
    ];
  };

  programs.zsh.enable = true;
}
