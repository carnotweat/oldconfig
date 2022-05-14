issoDockerImage = pkgs.dockerTools.buildImage {
  name = "isso";
  tag = "latest";
  extraCommands = ''
    mkdir -p db
  '';
  config = {
    Cmd = [ "${issoEnv}/bin/gunicorn"
            "--name" "isso"
            "--bind" "0.0.0.0:${port}"
            "--worker-class" "gevent"
            "--workers" "2"
            "--worker-tmp-dir" "/dev/shm"
            "--preload"
            "isso.run"
          ];
    Env = [
      "ISSO_SETTINGS=${issoConfig}"
      "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
    ];
  };
};
