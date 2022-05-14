{ config, pkgs, ... }:

let

  haskell-language-server = import (fetchTarball "https://github.com/haskell/haskell-language-server/tarball/master") {};
  

in {
  environment.systemPackages = with pkgs; [

    (haskell-language-server.selection { selector = p: { inherit (p) ghc865 ghc864; }; })

  ];
}
