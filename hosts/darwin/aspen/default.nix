{
  inputs,
  metadata,
  pkgs,
  ...
}:

{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    inputs.nix-homebrew.darwinModules.nix-homebrew
    ./homebrew.nix
    ./aerospace.nix
    ./sketchybar.nix
    ../../../modules/system/nix
    ../../../modules/system/fonts.nix
  ];

  nixpkgs.hostPlatform = metadata.hosts.aspen.system;

  nix = {
    settings.trusted-users = [ metadata.user.username ];
    linux-builder.enable = true;
    gc = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 3;
        Minute = 0;
      };
      options = "--delete-older-than 30d";
    };
  };

  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = metadata.user.username;
  };

  networking = {
    computerName = metadata.hosts.aspen.name;
    hostName = metadata.hosts.aspen.name;
    localHostName = metadata.hosts.aspen.name;
  };

  users.users.${metadata.user.username} = {
    home = metadata.user.homeDirectory;
    shell = pkgs.zsh;
  };

  system = {
    primaryUser = metadata.user.username;
    stateVersion = 6;
    configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

    defaults = {
      dock = {
        autohide = true;
        mru-spaces = false;
        show-recents = false;
        persistent-apps = [
          { app = "${metadata.user.homeDirectory}/Applications/Home Manager Apps/Ghostty.app"; }
          { app = "/Applications/Helium.app"; }
          { app = "${metadata.user.homeDirectory}/Applications/Home Manager Apps/Obsidian.app"; }
          { app = "${metadata.user.homeDirectory}/Applications/Home Manager Apps/Vesktop.app"; }
          { app = "${metadata.user.homeDirectory}/Applications/Home Manager Apps/Feishin.app"; }
        ];
      };
      finder = {
        AppleShowAllExtensions = true;
        CreateDesktop = false;
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "clmv";
        ShowPathbar = true;
      };
    };
  };

  security.pam.services.sudo_local.touchIdAuth = true;
  programs.zsh.enable = true;
  services.openssh.enable = true;

  environment.systemPackages = [ pkgs.nh ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = {
      inherit inputs metadata;
      isDarwin = true;
    };
    users.${metadata.user.username}.imports = [
      ./home.nix
      ../../../home
    ];
  };
}
