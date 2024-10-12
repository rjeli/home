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

      system.configurationRevision = self.rev or self.dirtyRev or null;
      # backcompat: read `darwin-rebuild changelog` before changing
      system.stateVersion = 5;

      services.nix-daemon.enable = true;
      nix.package = pkgs.nix;
      nix.settings.experimental-features = "nix-command flakes";

      users.users.eriggs = {
        name = "eriggs";
        home = "/Users/eriggs";
      };

      programs.zsh.enable = true;

      environment.systemPackages = with pkgs; [];

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

      home.sessionVariables = {
        EDITOR = "vim";
      };
      home.sessionPath = [
        "$HOME/bin"
        "$HOME/.cargo/bin"
        "/opt/homebrew/bin"
      ];

      home.packages = with pkgs; [
        deno
        dhall
        dhall-json
        uv
      ];

      programs.zsh = {
        enable = true;
        defaultKeymap = "emacs";
        history = {
          # save timestamp
          extended = true;
          ignoreDups = true;
          save = 999999999;
          size = 999999999;
        };
        shellAliases = {
          switch = "darwin-rebuild switch --flake ~/repos/home";
          history = "history 0";
          subl = "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl";
        };
        # added to .zshrc
        initExtra = ''
        setopt INC_APPEND_HISTORY

        function parse_git_branch() {
          git branch 2>/dev/null | sed -ne 's/^\* \(.*\)/[\1]/p'
        }
        setopt PROMPT_SUBST
        export PROMPT='%n %F{green}%1~ %F{blue}$(parse_git_branch)%f %% '
        '';
      };

      home.file.".vimrc".text = ''
      inoremap jk <Esc>
      '';

      /*
      programs.vim = {
        enable = true;
        defaultEditor = true;
        extraConfig = ''
        inoremap jk <Esc>
        '';
      };
      */
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
