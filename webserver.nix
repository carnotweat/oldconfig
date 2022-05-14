{
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    services.nginx = {
        enable = true;
        virtualHosts = {
            "target.example.com" = {
                locations."/".root = "/var/www/target.example.com";
		  forceSSL = true;
                enableACME = true;
            };
	    "www.target.example.com" = {
                forceSSL = true;
                enableACME = true;
                locations."/".extraConfig = "return 301 $scheme://target.example.com$request_uri;";
            };
        };
    };
     users.extraUsers.www-deploy = {
        isNormalUser = true;
        home = "/var/www/";
        openssh.authorizedKeys.keys = [ "ssh-rsa <your public key>" ];
    };
}