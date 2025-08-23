{
  description = "darwin flake";

  nixConfig = {
    experimental-features = [
      "nix-command"
      "flakes"
      "pipe-operators"
    ];

    lazy-trees = true;
    show-trace = true;
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nh = {
      url = "github:nix-community/nh";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixpkgs-25.05-darwin";
  };

  outputs =

    inputs@{
      self,

      nixpkgs,
      darwin,
      home-manager,

      nix-homebrew,
      homebrew-core,
      homebrew-cask,

      disko,
      nh,
      nixpkgs-stable,
    }:

    let

      inherit (builtins) mapAttrs;
      inherit (nixpkgs.lib.trivial) flip;

      fset = nixpkgs.lib.fileset;

      darwinMachines = {
        "Polygon-N002HCY2C5" = "eriggs";
        "rj-m4" = "eli";
      };

      collectNix = fset.fileFilter (f: f.type == "regular" && f.hasExt "nix");

      allModules = collectNix ./mod;
      darwinModules = collectNix ./mod/darwin;
      commonModules = fset.difference allModules darwinModules;

    in

    {
      darwinConfigurations = (flip mapAttrs) darwinMachines (
        host: user:
        darwin.lib.darwinSystem {
          specialArgs = rec {
            inherit user inputs;
            platform = "aarch64-darwin";
            repo = "/Users/${user}/repos/home";
            here = repo;
            # pkgs-stable = nixpkgs-stable.legacyPackages.${platform};
          };
          modules = (fset.union commonModules darwinModules |> fset.toList) ++ [
            (
              { platform, ... }:
              {
                nix = {
                  channel.enable = false;
                  settings = {
                    trusted-users = [
                      "@admin"
                      user
                    ];
                    experimental-features = "nix-command flakes pipe-operators";
                    accept-flake-config = true;
                  };
                };
                nixpkgs = {
                  hostPlatform = platform;
                  config.allowUnfree = true;
                  # overlays = import ./overlays.nix { inherit pkgs-stable; };
                };
              }
            )

          ];
        }
      );

      nixosConfigurations.vega = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./lib/digitalocean.nix
          disko.nixosModules.disko
          { disko.devices.disk.disk1.device = "/dev/vda"; }
          ./hosts/vega/configuration.nix
          ./hosts/vega/hardware.nix
        ];
      };
    };

}
