{ config, pkgs, ... }:

# let
#   shared = import ../../shared.nix;
#   machine = "nixos";
#   hostId = "ec64122f";

# in
# {
#    _module.args = {
#     inherit shared;
#   };

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

#  boot.loader.grub.device = "/dev/sda";   # (for BIOS systems only)
  boot.loader.systemd-boot.enable = true; # (for UEFI systems only)

  # Note: setting fileSystems is generally not
  # necessary, since nixos-generate-config figures them out
  # automatically in hardware-configuration.nix.
  #fileSystems."/".device = "/dev/disk/by-label/nixos";

  # Enable the OpenSSH server.
  services.sshd.enable = true;
}
