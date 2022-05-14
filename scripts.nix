let
  fish-shebang = "#!${pkgs.fish}/bin/fish";
  define-script = name: script: pkgs.writeScriptBin name script;
  define-fish-script = name: script: define-script name (fish-shebang + "\n\n" + script);
in {
  environment.systemPackages = [
    (define-fish-script "decrypt-folder" ''
      if test (count $argv) -eq 0
        echo "usage: decrypt-folder <folder>"
        exit
      end

      set name (string replace -r "\.tar\.gz\.gpg" "" $argv[1])

      gpg $name.tar.gz.gpg
      tar -xzf $name.tar.gz
      rm $name.tar.gz
    '')

    (define-fish-script "git-add-commit-push" ''
      git add .
      git commit -m "$argv[1]"
      git push
    '')
  ];
}