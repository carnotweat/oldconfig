services.nginx.virtualHosts."comments.luffy.cx" = {
  root = "/data/webserver/comments.luffy.cx";
  enableACME = true;
  forceSSL = true;
  extraConfig = ''
    access_log /var/log/nginx/comments.luffy.cx.log anonymous;
  '';
  locations."/" = {
    proxyPass = "http://127.0.0.1:${port}";
    extraConfig = ''
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header Host $host;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_hide_header Set-Cookie;
      proxy_hide_header X-Set-Cookie;
      proxy_ignore_headers Set-Cookie;
    '';
  };
};
security.acme.certs."comments.luffy.cx" = {
  email = lib.concatStringsSep "@" [ "letsencrypt" "vincent.bernat.ch" ];
};
