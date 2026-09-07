{ metadata, tokenFile }:

{
  type = "server-stats";

  servers = [
    {
      type = "local";
      name = metadata.hosts.elm.name;
    }
    {
      type = "remote";
      url = "http://${metadata.hosts.houseplants.name}.${metadata.tailnet.domain}:27973";
      name = metadata.hosts.houseplants.name;
      token = {
        _secret = tokenFile;
      };
    }
    {
      type = "remote";
      url = "http://${metadata.hosts.lovecomputer.name}.${metadata.tailnet.domain}:27973";
      name = metadata.hosts.lovecomputer.name;
      token = {
        _secret = tokenFile;
      };
    }
  ];
}
