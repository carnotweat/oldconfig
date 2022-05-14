# element
{
  imports =
    let
      nur-no-pkgs =
        import (
          builtins.fetchTarball
          "https://github.com/nix-community/NUR/archive/master.tar.gz"
        ) {};
    in

   
   services.nginx = {
   
   enable = true;
   
   virtualHosts = {

     ## virtual host for Syapse
     "matrix.dangerousdemos.net" = {
       ## for force redirecting HTTP to HTTPS
       forceSSL = true;
       ## this setting takes care of all LetsEncrypt business
       enableACME = true;
       locations."/" = {
         proxyPass = "http://localhost:8008";
       };
     };

     ## virtual host for Riot/Web
     "riot.dangerousdemos.net" = {
       ## for force redirecting HTTP to HTTPS
       forceSSL = true;
       ## this setting takes care of all LetsEncrypt business
       enableACME = true;
       ## root points to the element-web package content, also configured via Nix
       locations."/" = {
           root = pkgs.element-web;
       };
     };

     ## virtual host for Jitsi, reusing the same hostname as used
     ## while configuring jitsi-meet
     ${config.services.jitsi-meet.hostName} = {
       enableACME = true;
       forceSSL = true;
     };
   };

   ## other nginx specific best practices
   recommendedGzipSettings = true;
   recommendedOptimisation = true;
   recommendedTlsSettings = true;
 };
   services.matrix-synapse = {
    enable = true;

    ## domain for the Matrix IDs
    server_name = "dangerousdemos.net";

    ## enable metrics collection
    enable_metrics = true;

    ## enable user registration
    enable_registration = true;

    ## Synapse guys recommend to use PostgreSQL over SQLite
    database_type = "psycopg2";

    ## database setup clarified later
    database_args = {
      password = "synapse";
    };

    ## default http listener which nginx will passthrough to
    listeners = [
      {
        port = 8008;
        tls = false;
        resources = [
          {
            compress = true;
            names = ["client" "webclient" "federation"];
          }
        ];
      }
    ];

    ## coturn based TURN server integration (TURN server setup mentioned later),
    ## shared secret generated while configuring coturn
    ## and reused here (power of Nix being a real programming language)
    # turn_uris = [
    #   "turn:turn.dangerousdemos.net:3478?transport=udp"
    #   "turn:turn.dangerousdemos.net:3478?transport=tcp"
    # ];
    # turn_shared_secret = config.services.coturn.static-auth-secret;
  };
  services.postgresql = {
    enable = true;

    ## postgresql user and db name remains in the
    ## service.matrix-synapse.database_args setting which
    ## by default is matrix-synapse
    initialScript = pkgs.writeText "synapse-init.sql" ''
        CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD 'synapse';
        CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
            TEMPLATE template0
            LC_COLLATE = "C"
            LC_CTYPE = "C";
        '';
  };
    services.jitsi-meet = {
    enable = true;
    hostName = "jitsi.dangerousdemos.net";
    };

    ## this setting is going to add relevant ports to
    ## networking.firewall.allowedTCPPorts &
    ## networking.firewall.allowedUDPPorts
    ## videobridge.openFirewall = true;
 # };
    services.coturn = {
    enable = true;
    use-auth-secret = true;
    static-auth-secret = "jebCBjZSQhBgQiwH5eBO1mQpuH9uTxEWpES6Om2bp3n71XR6qcAmdtC9tPt4pptm";
    realm = "turn.dangerousdemos.net";
    no-tcp-relay = true;
    no-tls = true;
    no-dtls = true;
    extraConfig = ''
        user-quota=12
        total-quota=1200
        denied-peer-ip=10.0.0.0-10.255.255.255
        denied-peer-ip=192.168.0.0-192.168.255.255
        denied-peer-ip=172.16.0.0-172.31.255.255

        allowed-peer-ip=192.168.191.127
    '';
  };
  
  nixpkgs.overlays = [
    (self: super: {
        element-web = super.element-web.override {
            conf = {
                 default_server_config = {
                    "m.homeserver" = {
                        "base_url" = "https://matrix.dangerousdemos.net";
                        "server_name" = "dangerousdemos.net";
                    };
                    "m.identity_server" = {
                        "base_url" = "https://vector.im";
                    };
                 };

                 ## jitsi will be setup later,
                 ## but we need to add to Riot configuration
                 jitsi.preferredDomain = "jitsi.dangerousdemos.net";
            };
        };
    })
  ];
