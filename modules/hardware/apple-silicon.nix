{
  inputs,
  lib,
  pkgs,
  config,
  ...
}:

let
  fairydustPackages =
    pkgs.callPackage
      (
        {
          lib,
          callPackage,
          linuxPackagesFor,
          _kernelPatches ? [ ],
          ...
        }@args:

        let
          extraArgs = lib.removeAttrs args [
            "lib"
            "callPackage"
            "linuxPackagesFor"
            "_kernelPatches"
          ];

          linux-asahi-pkg =
            {
              stdenv,
              lib,
              fetchFromGitHub,
              buildLinux,
              ...
            }:
            buildLinux (
              lib.recursiveUpdate rec {
                inherit stdenv lib;

                pname = "linux-asahi";
                version = "7.1.5";
                modDirVersion = version;

                extraMeta.branch = "7.1";

                src = fetchFromGitHub {
                  owner = "AsahiLinux";
                  repo = "linux";
                  tag = "asahi-7.1.5-2";
                  hash = "sha256-z7S0YTmDshMK2frFhMm4M4wUOV3rPOwxPkR2IXk4R+Y=";
                };

                kernelPatches = [
                  {
                    name = "Asahi config";
                    patch = null;

                    structuredExtraConfig = with lib.kernel; {
                      ARM64_16K_PAGES = yes;
                      ARM64_MEMORY_MODEL_CONTROL = yes;
                      ARM64_ACTLR_STATE = yes;

                      APPLE_WATCHDOG = yes;
                      APPLE_M1_CPU_PMU = yes;

                      HID_APPLE = module;

                      APPLE_PMGR_MISC = yes;
                      APPLE_PMGR_PWRSTATE = yes;
                    };

                    features.rust = true;
                  }
                ]
                ++ _kernelPatches;
              } extraArgs
            );

          linux-asahi = callPackage linux-asahi-pkg { };
        in
        lib.recurseIntoAttrs (
          linuxPackagesFor linux-asahi
        )
      )
      {
        _kernelPatches = config.boot.kernelPatches;

        version = "7.1.13";
        modDirVersion = "7.1.13";

        src = pkgs.fetchFromGitHub {
          owner = "AsahiLinux";
          repo = "linux";
          rev = "ce9f2eba72c061a50b2d790450e90af3439d8c24";
          hash = "sha256-W3yMSUe6xa+M/X0k86kbCS4g3d7jJmO3WV9L/5rQRhI=";
        };
      };
in
{
  imports = [
    inputs.apple-silicon.nixosModules.default
  ];

  hardware.asahi = {
    enable = true;
    extractPeripheralFirmware = true;
    peripheralFirmwareDirectory = inputs.asahi-firmware;
  };

  boot.kernelPackages = lib.mkForce fairydustPackages;

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = false;
  };
}
