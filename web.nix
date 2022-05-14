{
    webserver = {
        deployment.targetHost = "target.example.com";
        networking.hostName = "target.example.com";
        imports = [ ./ramnode-kvm.nix
                    ./ssh.nix
                    ./webserver.nix
                  ];
    };
    network.description = "example network";
}