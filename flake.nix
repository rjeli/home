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

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixpkgs-25.05-darwin";
  };

  outputs =

    {
      self,

      nixpkgs,
      darwin,
      home-manager,

      nix-homebrew,
      homebrew-core,
      homebrew-cask,

      disko,
      nixpkgs-stable,
    }:

    let

      inherit (builtins) mapAttrs;
      inherit (nixpkgs.lib.trivial) flip;

      # pkgs-stable = import nixpkgs-stable { system = "aarch64-darwin"; };
      # todo dont hardcode system??
      pkgs-stable = nixpkgs-stable.legacyPackages.aarch64-darwin;

      darwinConfig =
        { user }:
        { pkgs, ... }:
        {
          # need newer nix for flake relative paths
          # todo use lix ?
          nix = {
            # package = pkgs.nixVersions.nix_2_26;
            /*
              linux-builder = {
                enable = true;
                systems = ["x86_64-linux"];
              };
            */
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
            hostPlatform = "aarch64-darwin";
            config.allowUnfree = true;
            overlays = import ./overlays.nix { inherit pkgs-stable; };
          };

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
          }
          // (import ./system.nix { });

          homebrew = import ./brew.nix { };

          environment.systemPackages = [
            # pull this from stable so it doesnt take ages to build
            # todo its broken on 25.05. https://github.com/nixos/nixpkgs/issues/421014
            # pkgs-stable.texlive.combined.scheme-full

            # pkgs.deno
          ];

          launchd.user.agents = {
            userscript_server = {
              # command = "/Users/${user}/repos/home/bin/userscript_server";
              command = "${pkgs.deno}/bin/deno run -A /Users/${user}/repos/home/bin/userscript_server";

              serviceConfig = {
                RunAtLoad = true;
                KeepAlive = true;
                StandardOutPath = "/tmp/userscript_server.out.log";
                StandardErrorPath = "/tmp/userscript_server.err.log";
              };
            };
          };

        };

      homeConfig =
        { pkgs, config, ... }:
        let
          here = "${config.home.homeDirectory}/repos/home";
        in
        import ./home.nix { inherit pkgs config here; };

      machines = {
        "Polygon-N002HCY2C5" = "eriggs";
        "rj-m4" = "eli";
      };

    in

    {
      darwinConfigurations = (flip mapAttrs) machines (
        host: user:
        darwin.lib.darwinSystem {
          modules = [

            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                enable = true;
                user = user;
                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                };
                mutableTaps = false;
                autoMigrate = true;
              };
            }
            (
              { config, ... }:
              {
                homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
              }
            )

            (darwinConfig { user = user; })

            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                verbose = true;
                backupFileExtension = "bak";
                users.${user} = homeConfig;
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
