{
  user = {
    username = "ivy";
    fullName = "ivy forever";
    homeDirectory = "/home/ivy";

    emails = {
      primary = "ivy@ivy.rs";
      gmail = "ivyturner78@gmail.com";
    };

    sshKeys = {
      aspen = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICtFawaAWSklr1GGYiBZzGr/ydKSSOatBfGfY72eqKGZ";
      alder = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEdNudbGaj76Gu5Kn9bKsTCb8cAMPM0lg/hS6TriaWY7";
    };
  };

  domains = {
    personal = "ivy.rs";
    services = "houseplants.cloud";
  };

  tailnet = {
    domain = "ocelot-perch.ts.net";
    ingressProxyIp = "100.64.20.1";
  };

  hosts = {
    alder = {
      name = "alder";
      system = "aarch64-linux";
    };
    elm = {
      name = "elm";
      system = "x86_64-linux";
    };
    yew = {
      name = "yew";
      system = "x86_64-linux";
    };
    houseplants = {
      name = "houseplants";
      system = "aarch64-linux";
    };
    scarecrow = {
      name = "scarecrow";
      system = "x86_64-linux";
    };

    aspen = {
      name = "aspen";
      system = "aarch64-darwin";
    };
    lovecomputer.name = "lovecomputer";
  };
}
