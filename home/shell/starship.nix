{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = " $username$hostname$directory$character";
      right_format = "$all";

      character = {
        success_symbol = ">";
        error_symbol = ">";
        vimcmd_symbol = "<";
      };

      git_branch = {
        format = "[$branch]($style)";
      };

      git_status = {
        format = "[[(* $conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)";
        style = "";
        conflicted = "";
        untracked = "u";
        modified = "m";
        staged = "s";
        renamed = "r";
        deleted = "x";
        stashed = "st";
      };

      git_state = {
        format = ''\([$state( $progress_current/$progress_total)]($style)\) '';
      };

      cmd_duration = {
        format = "[$duration]($style) ";
      };

      username = {
        format = "[$user]($style)[@](white)";
        disabled = false;
      };

      hostname = {
        ssh_symbol = " ssh";
        format = "[$hostname]($style)[$ssh_symbol](bold blue) ";
        trim_at = ".";
        #aliases = {
        #"aspen." = "aspen";
        #"elm.${meta.tailnet}" = "elm";
        #};
        disabled = false;
      };
    };
  };
}
