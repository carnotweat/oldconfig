{ config, lib, pkgs, ... }:
# abstract-structure
#with
#let
#in
## imports
#system.pkgs
#service enable
#user-enable
#version
# let
#   lib = pkgs.stdenv.lib;
#   workUser = "ec2-user";
#   workHosts = [ "*.example.net"
#                "192.168.1.*"
#               ];
# in 
{
   #  programs.ssh = {
  #   enable = true;
  #   forwardAgent = false;
  #   hashKnownHosts = true;
  #   controlMaster = "auto";
  #   controlPath = "~/.ssh/master-%r@%h:%p";

  #   matchBlocks = {
  #     "foo-host" = {
  #       hostname = "host.foo.tld";
  #       user = "root";
  #       port = 22;
  #       identityFile = "~/.ssh/id_ecdsa";
  #     };
  #     "bastion-proxy" = {
  #       hostname = "bastion.example.net";
  #       user = "ec2-user";
  #       port = 443;
  #       identityFile = "~/.ssh/id_rsa";
  #       identitiesOnly = true;
  #       dynamicForwards = [ { port = 8080; } ];
  #       extraOptions = {
  #         RequestTTY = "no";
  #       };
  #     };
  #     work = {
  #       host = (lib.concatStringsSep " " workHosts);
  #       user = workUser;
  #       proxyJump = "bastion-proxy";
  #       certificateFile = "~/.ssh/id_ecdsa-cert.pub";
  #       identitiesOnly = true;
  #     };
  # };
  imports =	      	     
    [ 
      #./hardware-configuration.nix
      #./cachix.nix
      # ./ssh.nix
      # ./overlay.nix
      
    ];

# system block
# Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

# zfs
boot.initrd.supportedFilesystems = [ "zfs" ]; 
boot.supportedFilesystems = [ "zfs" ]; 
services.udev.extraRules = ''
  ACTION=="add|change", KERNEL=="sd[a-z]*[0-9]*|mmcblk[0-9]*p[0-9]*|nvme[0-9]*n[0-9]*p[0-9]*", ENV{ID_FS_TYPE}=="zfs_member", ATTR{../queue/scheduler}="none"
'';


  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r rpool/local/root@blank
  '';

  
  networking.wireguard.interfaces.wg0 = {
    generatePrivateKeyFile = true;
    privateKeyFile = "/persist/etc/wireguard/wg0";
  };

# {
#   etc."NetworkManager/system-connections" = {
#     source = "/persist/etc/NetworkManager/system-connections/";
#   };
# }

  # services.openssh = {
  #   enable = true;
  #   hostKeys = [
  #     {
  #       path = "/persist/ssh/ssh_host_ed25519_key";
  #       type = "ed25519";
  #     }
  #     {
  #       path = "/persist/ssh/ssh_host_rsa_key";
  #       type = "rsa";
  #       bits = 4096;
  #     }
  #   ];
  # };



  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.wlp2s0.useDHCP = true;
  networking.networkmanager.enable = true;
  networking.hostId = "ec64122f";
  networking.hostName = "nixos";
  nixpkgs.config.allowUnfree = true;

# packages

environment.systemPackages = with pkgs; [
    vim 
    wget
    #devops
    appimage-run
    #docker
    docker-client
    docker-compose
    docker
    git
    #element
    element-desktop
    #homeserver
    #nginx
    apache-jena
    acme
    wireguard-tools
    terraform
    zfs
    #make
    #python
    python
    python3
    conda
    elixir
    # phone
    # android-studio
        (emacsWithPackagesFromUsePackage {
      # Your Emacs config file. Org mode babel files are also
      # supported.
      # NB: Config files cannot contain unicode characters, since
      #     they're being parsed in nix, which lacks unicode
      #     support.
      # config = ./emacs.org;
      config = ./emacs.el;

      # Package is optional, defaults to pkgs.emacs
      package = pkgs.emacsGit;

      # By default emacsWithPackagesFromUsePackage will only pull in
      # packages with `:ensure`, `:ensure t` or `:ensure <package name>`.
      # Setting `alwaysEnsure` to `true` emulates `use-package-always-ensure`
      # and pulls in all use-package references not explicitly disabled via
      # `:ensure nil` or `:disabled`.
      # Note that this is NOT recommended unless you've actually set
      # `use-package-always-ensure` to `t` in your config.
      alwaysEnsure = true;

      # For Org mode babel files, by default only code blocks with
      # `:tangle yes` are considered. Setting `alwaysTangle` to `true`
      # will include all code blocks missing the `:tangle` argument,
      # defaulting it to `yes`.
      # Note that this is NOT recommended unless you have something like
      # `#+PROPERTY: header-args:emacs-lisp :tangle yes` in your config,
      # which defaults `:tangle` to `yes`.
      alwaysTangle = true;

      # Optionally provide extra packages not in the configuration file.
      extraEmacsPackages = epkgs: [
        epkgs.cask
      ];

      # Optionally override derivations.
      override = epkgs: epkgs // {
        weechat = epkgs.melpaPackages.weechat.overrideAttrs(old: {
          patches = [ ./weechat-el.patch ];
        });
      };
    })
  ];
    nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
    }))
  ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # services.xserver.libinput.enable = true;
  # # log
  # {
  # services.nginx.virtualHosts."blog.example.com" = {
  #   root = "/var/www/blog.example.com";
  # };
  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  
  # Enable emacs daemon
  services.emacs.enable = true;
  # Configure keymap in X11
  services.xserver.layout = "us";

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Define a user account. 
  # Don't forget to set a password with ???passwd??? using the root account if you don't use the init# ialPassword field.
  
  users.users.florent = {
    isNormalUser = true;
    initialPassword = "secret";  # Define the user initial password
    extraGroups = [ "wheel" "adbusers" ]; # wheel to enable ???sudo??? for the user.
  };

  # users.users.openssh = {
  #   isSystemUser = true;
  #   #initialPassword = "secret";  # Define the user initial password
  #   extraGroups = [ "wheel" "openssh" ]; # wheel to enable ???sudo??? for the user.
  # };

  
# users.users.root.openssh.authorizedKeys.keys = [
#   "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCTabxMjmHQunw2TL9DivIjK72zIjqtqbM4t9xAyJ34FPrtIMm7H4GO8VAmx6YjPr9KAQKot4cu12Kyt7OgBZ6S8j2G12twhTi8TUolM+JqxOWcav5DSGL04ecyqRoQ/WFoak5y4c8n9ZPS8/oKyig2t+lInNWPOHB75BKlK7YScJwv+kNBEmOd+Z/Fns7aT72rjS1a4REx/9cStZZIgoCEuAhoXfblMBEgwhh1EgP+7bxFNoZN2LcO6TYzsEVcF8hockXU0yQipzY5a3t8L7CvOcErP8nOsfaOHprSpJgpeAJKhv4DwYNp09M79v7Zbb/hVvM41RyM65tc5kPXLbt+/3oGfJeVjU35BJUCqTz9p+JK3fHz0uWGpNTBYftwUsu/gAmo9RbFU6G7Apx4KBKAzIN56DIvNw/M44d/j3sXnNREJfOb0whH88seoWUrNyKNHjcgy6n1PJnLFWF0BPdIbtXYQxaCVlsPuxbS+xy6b/CEcCoKUbRTXYsmCIhUZaDhNxdWDBZNXgthWDX+Vg3CeWjZqGMBIYqxrxrhgzUt/0X59oc3K2v6EPJe9JQRTK1OeTbmiTRBpIbdL1Gxbw8yse6rTnASM5SZ6VpOrgepwl9DjgvZn7sOiq9cTc66sfXHrFYTGVQw8oWVLVEN9D05qPlNGhNwSG7ptkSHAwOsHQ== jasitis@gmail.com"
#   ];
  
#  programs.adb.enable = true;
  # serve over ssh
  # 	nix.buildMachines = [ {
	#  hostName = "builder";
	#  system = "x86_64-linux";
	#  # if the builder supports building for multiple architectures, 
	#  # replace the previous line by, e.g.,
	#  # systems = ["x86_64-linux" "aarch64-linux"];
	#  maxJobs = 1;
	#  speedFactor = 2;
	#  supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
	#  mandatoryFeatures = [ ];
	# }] ;
	# nix.distributedBuilds = true;
	# # optional, useful when the builder has a faster internet connection than yours
	# nix.extraOptions = ''
	# 	builders-use-substitutes = true
	# '';
	
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It???s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  # system.stateVersion = "21.05"; # Did you read the comment?

}
