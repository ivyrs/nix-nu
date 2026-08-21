{ pkgs, ... }:

{
  programs.emacs = {
    enable = true;

    package = pkgs.emacs-pgtk;

    extraPackages = epkgs:
      with epkgs; [
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

        (treesit-grammars.with-grammars (grammars:
          with grammars; [
            tree-sitter-javascript
            tree-sitter-typescript
            tree-sitter-tsx
            tree-sitter-astro
            tree-sitter-css
          ]))

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
