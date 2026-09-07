{ metadata }:

{
  type = "monitor";
  cache = "1m";
  title = "Services";

  sites = [
    {
      title = "nextcloud";
      url = "https://cloud.${metadata.domains.services}";
      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/png/nextcloud.png";
    }
    {
      title = "syncthing";
      url = "http://${metadata.hosts.elm.name}.${metadata.tailnet.domain}:8384";
      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/png/syncthing.png";
    }
    {
      title = "vaultwarden";
      url = "https://vault.${metadata.domains.services}";
      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/png/vaultwarden.png";
    }
    {
      title = "RSS";
      url = "https://rss.${metadata.domains.services}";
      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/png/miniflux.png";
    }
    {
      title = "houseplantsID";
      url = "https://id.${metadata.domains.services}";
      icon = "/assets/houseplants-logo.png";
    }
    {
      title = "forgejo";
      url = "https://git.${metadata.domains.services}";
      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/png/forgejo.png";
    }
    {
      title = "navidrome";
      url = "https://music.moose-amberjack.ts.net";
      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/png/navidrome.png";
    }
  ];
}
