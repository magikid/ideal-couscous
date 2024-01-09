# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  environment.shellAliases = {
    ls = "ls -l";
    la = "ls -a";
  };
  environment.systemPackages = with pkgs; [
    bat
    bc
    curl
    delta
    dnsutils
    fd
    git
    glibcLocales
    htop
    jq
    just
    magic-wormhole
    mosh
    ncdu
    ncmpcpp
    pv
    tailscale
    tmux
    vim
    wget
  ];

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  networking.hostName = "load-balancer-2"; # Define your hostname.
  networking.useDHCP = false;
  networking = {
    interfaces = {
      ens18.ipv4.addresses = [{
        address = "192.168.104.29";
        prefixLength = 24;
      }];
    };
    defaultGateway = {
      address = "192.168.104.1";
      interface = "ens18";
    };
  };
  networking.nameservers = [ "192.168.104.1" ];
  networking.firewall.enable = false;

  ## Garbage collection
  # https://nixos.wiki/wiki/Storage_optimization#Automation
  nix.gc = {
    automatic = true;
    dates = "Monday 01:00 America/Kentucky/Louisville";
    options = "--delete-older-than 7d";
  };

  # Run garbage collection whenever there is less than 500MB free space left
  nix.extraOptions = ''
    min-free = ${toString (500 * 1024 * 1024)}
  '';


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  security.pam.enableSSHAgentAuth = true;

  services.resolved = {
    enable = true;
    domains = [ "hilandchris.com" "vpn.hilandchris.com" ];
    fallbackDns = [ "45.90.28.65" "45.90.30.65" ];
  };
  services.qemuGuest.enable = true;
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  ## Unattended upgrade
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    dates = "weekly America/Kentucky/Louisville";
  };

  ## Optional: Clear >1 month-old logs
  systemd = {
    services.clear-log = {
      description = "Clear >1 month-old logs every week";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.systemd}/bin/journalctl --vacuum-time=30d";
      };
    };
    timers.clear-log = {
      wantedBy = [ "timers.target" ];
      partOf = [ "clear-log.service" ];
      timerConfig.OnCalendar = "weekly UTC";
    };
  };

  # Set your time zone.
  time.timeZone = "America/Kentucky/Louisville";

  users = {
    mutableUsers = false; # Disable passwd

    users = {
      root = {
        hashedPassword = "*"; # Disable root password
      };
      chrisj = {
        hashedPassword = "$y$jET$eQzDbgzetAjg3ybPY/lgn.$LQi1H9MqV47wJeZB7QB3n4J95Om3Gc.U813i4M5hX03";
        isNormalUser = true;
        extraGroups = [ "networkmanager" "wheel" ];
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
