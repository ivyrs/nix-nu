{
  pkgs,
  inputs,
  ...
}:

{
  home.packages = [
    inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.opencode
    # pi-coding-agent
    # inputs.oh-my-pi.packages.${stdenv.hostPlatform.system}.default
  ];
}
