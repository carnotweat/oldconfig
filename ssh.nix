let
  lib = pkgs.stdenv.lib;
  workUser = "ec2-user";
  workHosts = [ "*.example.net"
               "192.168.1.*"
              ];
in  

  programs.ssh = {
    enable = true;
    forwardAgent = false;
    hashKnownHosts = true;
    controlMaster = "auto";
    controlPath = "~/.ssh/master-%r@%h:%p"};

    matchBlocks = {
      "foo-host" = {
        hostname = "host.foo.tld";
        user = "root";
        port = 22;
        identityFile = "~/.ssh/id_ecdsa";
      };
      "bastion-proxy" = {
        hostname = "bastion.example.net";
        user = "ec2-user";
        port = 443;
        identityFile = "~/.ssh/id_rsa";
        identitiesOnly = true;
        dynamicForwards = [ { port = 8080; } ];
        extraOptions = {
          RequestTTY = "no";
        };
      };
      work = {
        host = (lib.concatStringsSep " " workHosts);
        user = workUser;
        proxyJump = "bastion-proxy";
        certificateFile = "~/.ssh/id_ecdsa-cert.pub";
        identitiesOnly = true;
      };
  };
