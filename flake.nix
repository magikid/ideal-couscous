{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/23.11";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # secret manager
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixhome = {
      url = "github:magikid/nix-home";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    sops-nix,
    nixhome,
    ...
  }: {
    nixosConfigurations = {
      default = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ./common/configuration.nix
          sops-nix.nixosModules.sops {
            sops = {
              defaultSopsFile = ./secrets/secrets.yaml;
              age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
              secrets = {
                "my-password" = {};
                "tailscale/auth_token" = {};
              };
            };
          }
        ];
      };

      "external-load-balancer.exocomet-cloud.ts.net" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ./hosts/external-load-balancer/configuration.nix
          sops-nix.nixosModules.sops {
            sops = {
              defaultSopsFile = ./secrets/secrets.yaml;
              age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
              secrets = {
                "my-password" = {};
                "tailscale/auth_token" = {};
                "digital_ocean/dns_token" = {};
                "cloudflare/dns_token" = {};
              };
            };
          }

          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.chrisj = import "${nixhome}/home.nix";
          }
        ];
      };

      "zigbee2mqtt.exocomet-cloud.ts.net" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ./hosts/zigbee2mqtt/configuration.nix

          sops-nix.nixosModules.sops {
            sops = {
              defaultSopsFile = ./secrets/secrets.yaml;
              age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
              secrets = {
                "my-password" = {};
                "tailscale/auth_token" = {};
                "mqtt/zigbee2mqtt/username" = {};
                "mqtt/zigbee2mqtt/password" = {};
              };
            };
          }

          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.chrisj = import "${nixhome}/home.nix";
          }
        ];
      };

      "nextcloud.exocomet-cloud.ts.net" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ./hosts/nextcloud/configuration.nix

          sops-nix.nixosModules.sops {
            sops = {
              defaultSopsFile = ./secrets/secrets.yaml;
              age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
              secrets = {
                "my-password" = {};
                "tailscale/auth_token" = {};
                "nextcloud/admin_password" = {};
              };
            };
          }

          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.chrisj = import "${nixhome}/home.nix";
          }
        ];
      };
    };
  };
}
