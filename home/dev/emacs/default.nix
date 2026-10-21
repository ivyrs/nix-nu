{ pkgs, ... }:

{
  programs.emacs = {
    enable = true;

    package = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.emacs else pkgs.emacs-pgtk;

    overrides = final: prev: {
      # GNU ELPA removed the 9.8.3 archive referenced by this nixpkgs revision.
      org = prev.org.overrideAttrs {
        version = "9.8.10";
        src = pkgs.fetchurl {
          url = "https://elpa.gnu.org/packages/org-9.8.10.tar";
          hash = "sha256-iQqd1cTx0nn27Qs9EGcNeWqsy3/ccaKmZc0VO+xGPx0=";
        };
      };
    };

    extraPackages =
      epkgs: with epkgs; [
        # Essentials
        use-package
        evil
        evil-collection
        evil-nerd-commenter
        which-key
        general
        restart-emacs
        exec-path-from-shell

        # UI
        catppuccin-theme
        doom-themes
        doom-modeline
        all-the-icons
        dashboard
        nerd-icons
        nyan-mode

        # Navigation / completion
        ivy
        counsel
        swiper
        company
        projectile

        # Git
        magit
        diff-hl

        # Terminal
        vterm
        vterm-toggle

        # Treesitter
        treesit-auto

        (treesit-grammars.with-grammars (
          grammars: with grammars; [
            tree-sitter-javascript
            tree-sitter-typescript
            tree-sitter-tsx
            tree-sitter-astro
            tree-sitter-css
            tree-sitter-yaml
          ]
        ))

        # Languages
        rust-mode
        typescript-mode
        astro-ts-mode
        nix-mode
        markdown-mode

        # Search
        rg

        # Org
        org-bullets
        org-roam

        # Performance
        gcmh
      ];

    extraConfig = builtins.readFile ./init.el;
  };
}
