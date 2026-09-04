{ config, lib, ... }:

let
  cfg = config.ivy.git.signing;
in
{
  options.ivy.git.signing = {
    enable = lib.mkEnableOption "Git SSH commit signing";

    key = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "SSH key to use for git signing";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.key != null;
        message = "ivy.git.signing.key must be set when Git signing is enabled";
      }
    ];

    xdg.configFile."git/allowed_signers".text = ''
      ivy@ivy.rs ${cfg.key}
    '';

    programs.git.settings = lib.mkIf (cfg.key != null) {
      user.signingkey = cfg.key;

      commit.gpgsign = true;

      gpg = {
        format = "ssh";

        ssh.allowedSignersFile = "${config.xdg.configHome}/git/allowed_signers";
      };
    };
  };

}
