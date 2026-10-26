{ inputs, ... }:
{
  imports = [ inputs.umbriel.nixosModules.default ];

  # Installs Umbriel, registers its session with the display manager (ly),
  # and sets up xdg-desktop-portal-umbriel for screen sharing.
  programs.umbriel.enable = true;
}
