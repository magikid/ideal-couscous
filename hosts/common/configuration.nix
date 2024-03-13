# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    bat
    bc
    curl
    delta
    dnsutils
    fd
    git
    glibcLocales
    home-manager
    htop
    jq
    just
    magic-wormhole
    mosh
    ncdu
    ncmpcpp
    pv
    sudo
    tailscale
    tmux
    vim
    wget
    zsh
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

  services.qemuGuest.enable = true;
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  services.tailscale.enable = true;

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
    services.tailscale-autoconnect = {
      description = "Automatic connection to Tailscale";

      # make sure tailscale is running before trying to connect to tailscale
      after = [ "network-pre.target" "tailscale.service" ];
      wants = [ "network-pre.target" "tailscale.service" ];
      wantedBy = [ "multi-user.target" ];

      # set this service as a oneshot job
      serviceConfig.Type = "oneshot";

      # have the job run this shell script
      script = with pkgs; ''
        # wait for tailscaled to settle
        sleep 2

        # check if we are already authenticated to tailscale
        status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
        if [ $status = "Running" ]; then
          exit 0
        fi

        # otherwise authenticate with tailscale
        ${tailscale}/bin/tailscale up -authkey $(< ${config.sops.secrets."tailscale/auth_token".path})
      '';
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  # Set your time zone.
  time.timeZone = "America/Kentucky/Louisville";
  sops.secrets.my-password.neededForUsers = true;
  users = {
    mutableUsers = false; # Disable passwd

    users = {
      root = {
        hashedPassword = "*"; # Disable root password
      };
      chrisj = {
        hashedPasswordFile = config.sops.secrets."my-password".path;
        isNormalUser = true;
        extraGroups = [ "networkmanager" "wheel" ];
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCz3bvIgjt2F9fxRDHuR6jRcCdpi3itDHir3Tq70hcodwGOz1xTS6+bPEvrU1qlimevmfSLluWmQGk60AxhclS6obOyLwUcKKUz71djxX+6ogInxIFzQ3BWfYrDy1G19ot6kRm/opIH16yWVqDpA35pwfxXtxNqs3dQkNLQvZckokOm+WOJ0SZAJKXXd6u+66Z2JHoASD5D3VaCfyquUGuVmlWd5nIr9vqVo/JywLTkmaf7wRuu4ejT1bd4dOFXB/sSNCU/4K4qBunABaYKf6cuIhbY7yYEh9YvAk6F+opO132E/4x9YMVGrbcL4lyJ03P/yZ1sZwFxuP4TvO7qUOXewh46xJ0PeOx9BfodztaZIG0X1ilcnFwIlLhQ89xgbDad8otpqSSXzAAHGEnDMQpk+D0A6y2BcVBouYzw2f328FiJzDCgLYK4DnNFcnc7LktBZyJQBqWGJGv8LHGXqS2BZjf3x334HHxzv35tilE46C0UCS8SDI53yITi7/7P/juJAgWUszI6DqL+0ffkklOCy0+Id6lLBcObzTEKJ+EdfNylHrHYZ2JD3MZsXlsloNuJnXw6E1aboYcxXWJXEt7L3N73A3VO76w3xITwbSBIcEsPmbZRebi8x9yJYU8myZLEc8mav9BKl6Dsm6m5Rk+YHXdBUsLRT0YGXr9vlAoj+Q=="
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBA3/OeC/ibOasuyJfPPzHlR8XhyRw1yGBJsv1yQw/qu"
        ];
        shell = pkgs.zsh;
        ignoreShellProgramCheck = true;
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
