{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";

    # hardware support
    apple-silicon = {
      url = "github:nix-community/nixos-apple-silicon/release-2026-07-30";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # it makes macs go :eyes:
    asahi-firmware = {
      url = "path:/etc/nixos/asahi-firmware";
      flake = false;
    };

    # speaking in tongues (age encrypted strings)
    sops = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # symlink everything
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # wallpaper engine
    noctalia.url = "github:noctalia-dev/noctalia";

    nvf.url = "github:NotAShelf/nvf/v26.07";

    # format all the things
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      treefmt-nix,
      ...
    }:
    let
      systems = [
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

      treefmtEval = forAllSystems (
        system:
        treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} {
          programs.nixfmt.enable = true;
        }
      );
    in
    {
      nixosConfigurations.alder = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";

        specialArgs = {
          inherit inputs;
        };

        modules = [
          ./hosts/nixos/alder
        ];
      };

      homeModules = {
        shell = ./home/shell;
        tmux = ./home/tmux;
        git = ./home/git;

        nvim = ./home/neovim/core.nix;
        nvim-full = ./home/neovim;

        niri = ./home/niri;
        ghostty = ./home/ghostty.nix;
        noctalia = ./home/noctalia;

        default = {
          imports = [
            ./home/shell
            ./home/git
            ./home/neovim/core.nix
            ./home/tmux
          ];
        };

        desktop = {
          imports = [
            ./home/niri
            ./home/noctalia
            ./home/ghostty.nix
          ];
        };
      };

      formatter = forAllSystems (system: treefmtEval.${system}.config.build.wrapper);

      checks = forAllSystems (system: {
        formatting = treefmtEval.${system}.config.build.check self;
      });

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              just
              nil
            ];
          };
        }
      );
    };
}
