{ metadata, ... }:

{
  imports = [
    ../../../home/scripts
  ];

  ivy.git.signing = {
    enable = true;
    key = metadata.user.sshKeys.aspen;
  };

  home.file.".ssh/authorized_keys".text = ''
    ${metadata.user.sshKeys.aspen} ${metadata.user.username}@${metadata.hosts.aspen.name}
  '';
}
