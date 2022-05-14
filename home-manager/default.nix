imports = [
  "${builtins.fetchGit {
    url = "https://github.com/rycee/home-manager";
    ref = "f856c78a4a220f44b64ce5045f228cbb9d4d9f31";
  }}/nixos"

  ./git.nix
];
