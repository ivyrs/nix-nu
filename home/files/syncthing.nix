{ ... }:

let
  home = "/home/ivy";
  devices = {
    elm = "TJPGEOG-GD5YAMM-47UEI4V-XTTAS4J-USDHS2B-JLNX4ED-NBEBUPF-WMYMOAC";
    maple = "5JH2CJ6-GEFOZAI-YTE2HIW-EK2NNHG-4CATBIM-WA4F2ZD-HUFTQIN-QXCBJAI";
    birch = "IGGM65Q-7D3CXXE-WL2DZBQ-JFTAVZH-2IGGI3T-NNSEIOE-Y26ERF2-357RMQM";
  };
in
{
  services.syncthing = {
    enable = true;

    overrideDevices = true;
    overrideFolders = true;

    settings = {
      devices = {
        elm.id = devices.elm;
        maple.id = devices.maple;
        birch.id = devices.birch;
      };

      folders = {
        obsidian = {
          id = "obsidian-vault";
          path = "${home}/text/obsidian";
          devices = [
            "elm"
            "maple"
            "birch"
          ];
          ignorePerms = true;
        };
      };

      options.urAccepted = -1;
    };
  };
}
