{ config, ... }:

let
  devices = {
    aspen = "34BRASD-JF433B5-65QROJF-7WRJZ74-LISAYBR-4ADQBVC-XXX672X-O7IAJA6";
    alder = "IW3IYSH-QZZXLNV-553NXOQ-5EPBYLW-3MWQJJB-3JEEZB2-H7JIKSQ-NW4C6A2";
    maple = "5JH2CJ6-GEFOZAI-YTE2HIW-EK2NNHG-4CATBIM-WA4F2ZD-HUFTQIN-QXCBJAI";
    birch = "IGGM65Q-7D3CXXE-WL2DZBQ-JFTAVZH-2IGGI3T-NNSEIOE-Y26ERF2-357RMQM";
  };
in
{
  services.syncthing = {
    enable = true;

    dataDir = "/var/lib/syncthing";
    configDir = "/var/lib/syncthing/.config/syncthing";

    openDefaultPorts = true;
    overrideDevices = true;
    overrideFolders = true;

    guiAddress = "0.0.0.0:8384";
    guiPasswordFile = config.sops.secrets.syncthing-gui-password.path;

    settings = {
      options.urAccepted = -1;

      gui = {
        address = "0.0.0.0:8384";
        user = "ivy";
      };

      devices = {
        aspen.id = devices.aspen;
        alder.id = devices.alder;
        maple.id = devices.maple;
        birch.id = devices.birch;
      };

      folders.obsidian = {
        id = "obsidian-vault";
        path = "/var/lib/syncthing/obsidian";

        devices = [
          "aspen"
          "alder"
          "maple"
          "birch"
        ];

        ignorePerms = true;

        versioning = {
          type = "staggered";

          params = {
            cleanInterval = "3600";
            maxAge = "2592000";
          };
        };
      };
    };

  };

  sops.secrets.syncthing-gui-password.owner = "syncthing";
}
