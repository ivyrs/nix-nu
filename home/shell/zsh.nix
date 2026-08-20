{
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "brew"
        "eza"
      ];
    };

    initContent = ''
      zstyle ':completion:*' menu select
    '';

    shellAliases = {
      e = "nvim";

      # base aliases from https://github.com/plttn/fish-eza
      l = "eza --group --header --group-directories-first";
      ls = "eza --group --header --group-directories-first";
      ll = "eza --group --header --group-directories-first --long --git";
      le = "eza --group --header --group-directories-first --extended --long";
      lt = "eza --group --header --group-directories-first --tree --level";
      lc = "eza --group --header --group-directories-first --across";
      lo = "eza --group --header --group-directories-first --oneline";

      la = "eza -la";
      lsa = "eza -la";
      lta = "eza -T -a";
      tree = "eza --group --header --group-directories-first --tree";

      cat = "bat";
      df = "duf";
      top = "btop";
      grep = "rg";
      du = "dust";
      ps = "procs";

      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "-" = "cd -";

      c = "clear";
      mkdir = "mkdir -p";
      reload = "exec zsh";
      lg = "lazygit";
      j = "just";

      # nix maintenance
      nixgc = "nix-collect-garbage -d";
      nixgens = "nix-env --list-generations -p /nix/var/nix/profiles/system";

      ports = "lsof -i -P -n | grep LISTEN";
    };
  };
}
