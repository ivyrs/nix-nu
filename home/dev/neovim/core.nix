{
  imports = [
    ./module.nix
  ];

  programs.nvf = {
    enable = true;

    settings = {
      imports = [
        ./config/core.nix
      ];
    };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
