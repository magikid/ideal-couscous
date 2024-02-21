{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/23.11";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # secret manager
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    sops-nix,
    ...
  }: {
    nixosConfigurations = {
      # default = nixpkgs.lib.nixosSystem {
      #   system = "x86_64-linux";

      #   modules = [ ./common/configuration.nix ];
      # };
      "load-balancer-2" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ./hosts/load-balancer-2/configuration.nix
          sops-nix.nixosModules.sops {
            sops = {
              defaultSopsFile = ./secrets/secrets.yaml;
              age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
              secrets = {
                "zigbee2mqtt/mqtt_username" = {};
                "zigbee2mqtt/mqtt_password" = {};
              };
            };
          }
        ];
      };

      "external-load-balancer.hilandchris.com" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ./hosts/external-load-balancer/configuration.nix
          sops-nix.nixosModules.sops {
            sops = {
              defaultSopsFile = ./secrets/secrets.yaml;
              age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
              secrets = {
                "digital_ocean/dns_token" = {};
                "cloudflare/dns_token" = {};
                "tailscale/auth_token" = {};
              };
            };
          }
        ];
      };
    };
  };
}
