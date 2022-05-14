issoConfig = pkgs.writeText "isso.conf" ''
  [general]
  dbpath = /db/comments.db
  host =
    https://vincent.bernat.ch
    http://localhost:8080
  notify = smtp
  […]
'';