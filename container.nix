virtualisation.oci-containers = {
  backend = "podman";
  containers = {
    "redis" = {
      image = "redis:6-alpine";
      cmd = [ "redis-server" "--port" "6379" "--user" "username" ];
      ports = [ "6379:6379" ];
    };
  };
};