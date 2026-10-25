# pkgs/lazytailscale.nix
# Usage: home.packages = [ (pkgs.callPackage ./pkgs/lazytailscale.nix { }) ];
{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "lazytailscale";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "mogglemoss";
    repo = "lazytailscale";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cPT/cdLE5i2+W2EE8+CZ6CRa610M+AO8c77GIfyypmw=";
  };

  vendorHash = "sha256-oSS5zReLZSaGMTMK3YQZqwGMXORywXl421x4VzF3Wc0=";

  ldflags = [
    "-s"
    "-w"
  ];

  doCheck = false;

  meta = {
    description = "Terminal dashboard for your Tailscale network";
    homepage = "https://github.com/mogglemoss/lazytailscale";
    license = lib.licenses.mit;
    mainProgram = "lazytailscale";
  };
})
