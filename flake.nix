{
  description = "darwin flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =

    {
      self,
      darwin,
      home-manager,
      nixpkgs,
    }:

    let

      inherit (builtins) mapAttrs;
      inherit (nixpkgs.lib.trivial) flip;

      darwinConfig =
        { user }:
        { pkgs, ... }:
        {
          # need newer nix for flake relative paths
          # todo use lix ?
          nix = {
            package = pkgs.nixVersions.nix_2_26;
            /*
              linux-builder = {
                enable = true;
                systems = ["x86_64-linux"];
              };
            */
            settings = {
              trusted-users = [
                "@admin"
                user
              ];
              experimental-features = "nix-command flakes";
              accept-flake-config = true;
            };
          };

          nixpkgs = {
            hostPlatform = "aarch64-darwin";
            config.allowUnfree = true;
            overlays = import ./overlays.nix { };
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
          } // (import ./system.nix { });

          homebrew = import ./brew.nix { };

          environment.systemPackages = [ ];

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
    };

}
