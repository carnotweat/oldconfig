environment.systemPackages = [
  pkgs.gitAndTools.gitFull # gitFull contains libsecret.
]

home-manager.users.rik.programs.git = {
  enable = true;

  # Some omitted settings.

  extraConfig = {
    credential.helper = "libsecret";
  };
};