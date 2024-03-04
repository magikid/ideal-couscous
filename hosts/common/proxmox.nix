# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./configuration.nix
      ./proxmox-hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  environment.shellAliases = {
    ls = "ls -l";
    la = "ls -a";
  };

  networking.useDHCP = false;
  networking = {
    interfaces = {
      ens18.ipv4.addresses = [{
        address = "192.168.104.100";
        prefixLength = 24;
      }];
    };
    defaultGateway = {
      address = "192.168.104.1";
      interface = "ens18";
    };
  };
  networking.nameservers = [ "192.168.104.1" ];

  services.resolved = {
    enable = true;
    domains = [ "hilandchris.com" "vpn.hilandchris.com" ];
    fallbackDns = [ "45.90.28.65" "45.90.30.65" ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
