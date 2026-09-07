{ metadata, pkgs, ... }:

{
  users.users.${metadata.user.username} = {
    isNormalUser = true;

    extraGroups = [
      "wheel"
      "networkmanager"
    ];

    shell = pkgs.zsh;

    # TODO: add alder's key back here
    openssh.authorizedKeys.keys = [
      "${metadata.user.sshKeys.aspen} ${metadata.user.username}@${metadata.hosts.aspen.name}"
    ];
  };

  programs.zsh.enable = true;
}
