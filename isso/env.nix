issoEnv = pkgs.python3.buildEnv.override {
    extraLibs = [
      issoPackage
      pkgs.python3Packages.gunicorn
      pkgs.python3Packages.gevent
    ];
};