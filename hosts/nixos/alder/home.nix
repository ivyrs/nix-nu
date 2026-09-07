{ metadata, ... }:

{
  imports = [
    ../../../home/scripts
  ];
  ivy.git.signing = {
    enable = true;
    key = metadata.user.sshKeys.alder;
  };
}
