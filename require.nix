...
let
  emacsForCI = pkgs.emacsWithPackagesFromPackageRequires {
    packageElisp = builtins.readFile ./flycheck.el;
    extraEmacsPackages = epkgs: [
      epkgs.package-lint
    ];
  };
pkgs.mkShell {
  buildInputs = [ emacsForCI ];
}