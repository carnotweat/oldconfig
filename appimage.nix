appimageTools.wrapType2 { # or wrapType1
  name = "patchwork";
  src = fetchurl {
    url = "https://github.com/ssbc/patchwork/releases/download/v3.11.4/Patchwork-3.11.4-linux-x86_64.AppImage";
    sha256 = "1blsprpkvm0ws9b96gb36f0rbf8f5jgmw4x6dsb1kswr4ysf591s";
  };
  extraPkgs = pkgs: with pkgs; [ ];
}