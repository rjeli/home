{
  description = "darwin flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, darwin, home-manager }:
  let
    darwinConfig = { pkgs, ... }: {
      nixpkgs.hostPlatform = "aarch64-darwin";

      # backcompat: read `darwin-rebuild changelog` before changing
      system.stateVersion = 5;

      services.nix-daemon.enable = true;
      nix.package = pkgs.nix;
      nix.settings.experimental-features = "nix-command flakes";
      system.configurationRevision = self.rev or self.dirtyRev or null;

      programs.zsh.enable = true;

      environment.systemPackages = [
        pkgs.deno
        pkgs.dhall
        pkgs.dhall-json
        pkgs.neofetch
        pkgs.uv
      ];

      system.defaults = {
        dock.autohide = true;
        trackpad.Clicking = true;
        finder = {
          AppleShowAllExtensions = true;
          ShowPathbar = true;
          FXEnableExtensionChangeWarning = false;
        };
      };

      system.keyboard = {
        enableKeyMapping = true;
        remapCapsLockToControl = true;
      };

      homebrew = {
        enable = true;
        onActivation.cleanup = "uninstall";
        brews = [];
        casks = [
          "alt-tab"
          "iterm2"
        ];
      };

      security.pam.enableSudoTouchIdAuth = true;
    };
    homeConfig = { pkgs, ... }: {
      home.stateVersion = "24.05";
      # programs.home-manager.enable = true;
      home.packages = with pkgs; [];
      # home.sessionVariables = {EDITOR = "vim"; };
    };
  in
  {
    darwinConfigurations."Polygon-N002HCY2C5" = darwin.lib.darwinSystem {
      modules = [
        darwinConfig
        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.verbose = true;
          home-manager.users.eriggs = homeConfig;
        }
      ];
    };
  };
}
