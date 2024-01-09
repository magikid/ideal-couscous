{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/23.11";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:nixos/nixos-hardware";
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, ... }: {
    nixosConfigurations = {
      default = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [ ./common/configuration.nix ];
      };
      "load-balancer-2" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ./hosts/common/configuration.nix
          ./hosts/load-balancer-2/configuration.nix
        ];
      };
    };
  };
}
