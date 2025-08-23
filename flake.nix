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
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixpkgs-25.05-darwin";

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

  };

  outputs =

    inputs@{
      self,

      nixpkgs,
      darwin,
      home-manager,
      nixpkgs-stable,

      disko,
      nh,

      ...
    }:

    let

      inherit (builtins) mapAttrs readDir;
      inherit (nixpkgs.lib)
        flatten
        mapAttrsToList
        flip
        hasSuffix
        hasInfix
        ;

      nixConfig =
        { platform, user, ... }:
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
          };
        };

      darwinMachines = {
        "Polygon-N002HCY2C5" = "eriggs";
        "rj-m4" = "eli";
      };

      modulesForPlatform =
        platform:
        let
          collect =
            dir:
            readDir dir
            |> mapAttrsToList (
              name: type:
              let
                fullName = dir + "/${name}";
              in
              if type == "regular" && hasSuffix ".nix" name then
                [ fullName ]
              else if type == "directory" && hasInfix name platform then
                collect fullName
              else
                [ ]
            )
            |> flatten;
        in
        collect ./mod;

    in

    {
      darwinConfigurations = (flip mapAttrs) darwinMachines (
        host: user:
        darwin.lib.darwinSystem {
          specialArgs = inputs // rec {
            inherit user;
            platform = "aarch64-darwin";
            repo = "/Users/${user}/repos/home";
            repoSrc = ./.;
            pkgs-stable = nixpkgs-stable.legacyPackages.${platform};
          };
          modules = (
            [
              nixConfig
            ]
            ++ (modulesForPlatform "aarch64-darwin")
          );
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
