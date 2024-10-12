{
  description = "darwin flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      nixpkgs.hostPlatform = "aarch64-darwin";

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      nix.package = pkgs.nix;
      nix.settings.experimental-features = "nix-command flakes";

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      programs.zsh.enable = true;
      environment.systemPackages = [];

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
        brews = [
          "dhall"
          "dhall-json"
          "uv"
        ];
        casks = [
          "alt-tab"
          "iterm2"
        ];
      };

      security.pam.enableSudoTouchIdAuth = true;
    };
  in
  {
    darwinConfigurations."Polygon-N002HCY2C5" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };
  };
}
