{ inputs, ... }:

{
  imports = [
    inputs.apple-silicon.nixosModules.default
  ];

  hardware.asahi = {
    enable = true;
    extractPeripheralFirmware = true;
    peripheralFirmwareDirectory = inputs.asahi-firmware;
  };

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = false;
  };
}
