{
  description = "darwin flake";

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
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixpkgs-25.05-darwin";
  };

  outputs =

    {
      self,
      nixpkgs,
      darwin,
      home-manager,
      nixpkgs-stable,
    }:

    let

      inherit (builtins) mapAttrs;
      inherit (nixpkgs.lib.trivial) flip;

      # pkgs-stable = import nixpkgs-stable { system = "aarch64-darwin"; };
      # todo dont hardcode system?
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
          } // (import ./system.nix { });

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
