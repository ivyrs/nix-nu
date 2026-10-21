{ pkgs, ... }:
{
  programs.niri.enable = true;
  # File selection uses GTK rather than GNOME's Nautilus-backed portal.
  programs.niri.useNautilus = false;

  environment.systemPackages = with pkgs; [
    xwayland-satellite
  ];
}
