{
  type = "monitor";
  cache = "1m";
  title = "Services";

  sites = [
    {
      title = "nextcloud";
      url = "https://cloud.houseplants.cloud";
      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/png/nextcloud.png";
    }
    {
      title = "syncthing";
      url = "http://elm.ocelot-perch.ts.net:8384";
      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/png/syncthing.png";
    }
    {
      title = "vaultwarden";
      url = "https://vault.houseplants.cloud";
      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/png/vaultwarden.png";
    }
    {
      title = "RSS";
      url = "https://rss.houseplants.cloud";
      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/png/miniflux.png";
    }
    {
      title = "houseplantsID";
      url = "https://id.houseplants.cloud";
      icon = "/assets/houseplants-logo.png";
    }
    {
      title = "forgejo";
      url = "https://git.houseplants.cloud";
      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/png/forgejo.png";
    }
    {
      title = "navidrome";
      url = "https://music.moose-amberjack.ts.net";
      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/png/navidrome.png";
    }
  ];
}
