{ tokenFile }:

{
  type = "server-stats";

  servers = [
    {
      type = "local";
      name = "elm";
    }
    {
      type = "remote";
      url = "http://houseplants.ocelot-perch.ts.net:27973";
      name = "houseplants";
      token = {
        _secret = tokenFile;
      };
    }
    {
      type = "remote";
      url = "http://lovecomputer.ocelot-perch.ts.net:27973";
      name = "lovecomputer";
      token = {
        _secret = tokenFile;
      };
    }
  ];
}
