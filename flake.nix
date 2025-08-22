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

      inherit (builtins) filter mapAttrs readDir;
      inherit (nixpkgs.lib.trivial) flip;
      inherit (nixpkgs.lib.filesystem) listFilesRecursive;
      inherit (nixpkgs.lib.strings) hasSuffix;

      here = "/Users/eli/repos/home";

      # pkgs-stable = import nixpkgs-stable { system = "aarch64-darwin"; };
      # todo dont hardcode system??
      pkgs-stable = nixpkgs-stable.legacyPackages.aarch64-darwin;

      darwinConfig =
        {
          pkgs,
          config,
          user,
          platform,
          ...
        }:
        {
          users.users.${user} = {
            name = user;
            home = "/Users/${user}";
          };

          programs.zsh.enable = true;

          security.pam.services.sudo_local.touchIdAuth = true;

          system = {
            configurationRevision = self.rev or self.dirtyRev or null;
            # backcompat: read `darwin-rebuild changelog` before changing
            # todo:             ^ broken
            stateVersion = 5;
            primaryUser = user;
          };

          environment.systemPackages = [
            # pull this from stable so it doesnt take ages to build
            # todo its broken on 25.05. https://github.com/nixos/nixpkgs/issues/421014
            # pkgs-stable.texlive.combined.scheme-full
            nh.packages.${platform}.default
          ];

        };

      darwinMachines = {
        "Polygon-N002HCY2C5" = "eriggs";
        "rj-m4" = "eli";
      };

      darwinModules = listFilesRecursive ./mod/darwin |> filter (hasSuffix ".nix");

    in

    {
      darwinConfigurations = (flip mapAttrs) darwinMachines (
        host: user:
        darwin.lib.darwinSystem {
          specialArgs = {
            inherit user here inputs;
            platform = "aarch64-darwin";
            repo = "/Users/${user}/repos/home";
          };
          modules =
            darwinModules
            ++ ([ ./mod/link.nix ])
            ++ [
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
                    overlays = import ./overlays.nix { inherit pkgs-stable; };
                  };
                }
              )

              darwinConfig

              # ./mod/system-defaults.nix
              # ./mod/hammerspoon.nix
              # ./mod/mas.nix
              # ./mod/brew.nix
              # ./mod/link.nix
              # ./mod/launchd.nix

              home-manager.darwinModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  verbose = true;
                  backupFileExtension = "bak";
                  extraSpecialArgs = { inherit here; };
                  users.${user} = {
                    imports = [ ./home.nix ];
                  };
                };
              }

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
