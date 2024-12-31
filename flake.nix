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
      nix.settings = {
        experimental-features = "nix-command flakes";
        substituters = [
          "https://cache.nixos.org"
          "https://devenv.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        ];
      };

      # todo figure out how to not hardcode?
      # https://github.com/nix-community/home-manager/issues/4026
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
          AppleShowAllFiles = true;                 # show hidden
          AppleShowAllExtensions = true;
          ShowPathbar = true;
          FXPreferredViewStyle = "Nlsv";            # list view
          FXEnableExtensionChangeWarning = false;
          _FXShowPosixPathInTitle = true;
          CreateDesktop = false;                    # no icons on desktop
        };
      };

      system.keyboard = {
        enableKeyMapping = true;
        remapCapsLockToControl = true;
      };

      homebrew = {
        enable = true;
        global.autoUpdate = false;
        onActivation.cleanup = "uninstall";
        brews = [
          "winetricks"
          "zenity"
        ];
        casks = [
          "alt-tab"
          "eloston-chromium"
          "ghostty"
          "iterm2"
          "wine-stable"
          "zotero"

          "ra3xdh/qucs-s/qucs-s@nightly"
        ];
      };

      security.pam.enableSudoTouchIdAuth = true;
    };

    homeConfig = { pkgs, config, ... }: {
      home.stateVersion = "24.05";

      home.sessionVariables = {
        EDITOR = "vim";
      };
      home.sessionPath = [
        "$HOME/bin"
        "$HOME/.cargo/bin"
        "/opt/homebrew/bin"
      ];

      home.packages = (with pkgs; [ 
        # tools
        devenv
        jq
        neovim
        pkg-config
        radare2
        ripgrep
        uv

        # libs
        qt5.qtbase qt5.qttools

        # languages
        deno 
        dhall dhall-docs dhall-json dhall-lsp-server
        octaveFull
        (sage.override { requireSageTests = false; })

        # blender
        # (octaveFull.withPackages (opkgs: with opkgs; [ ltfat ]))
        # (octave.withPackages (opkgs: with opkgs; [ symbolic splines ]))
        # octavePackages.ltfat
        # ((octave.override { enableQt = true; }).withPackages (opkgs: with opkgs; [ ltfat ]))
      ]) ++ [
        (let emacs = (pkgs.emacs29-macport.override {
          withTreeSitter = true; }); in (pkgs.emacsPackagesFor
          emacs).emacsWithPackages (epkgs: with epkgs; [
          treesit-grammars.with-all-grammars ])) 
      ];

      programs.zsh = {
        enable = true;
        enableCompletion = true;
        enableVteIntegration = true;
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
          subl = ''"/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl"'';
        };
        # added to .zshrc
        initExtra = (builtins.readFile ./.zshrc);
      };

      home.file.".vimrc".text = ''
      inoremap jk <Esc>
      '';

      home.file.".emacs.d/early-init.el" = {
        source = config.lib.file.mkOutOfStoreSymlink "/Users/eriggs/repos/home/.emacs.d/early-init.el";
      };
      home.file.".emacs.d/init.el" = {
        source = config.lib.file.mkOutOfStoreSymlink "/Users/eriggs/repos/home/.emacs.d/init.el";
      };

      programs.git = {
        enable = true;
        userName = "rjeli";
        userEmail = "eli@rje.li";
        aliases = {
          s = "status";
          co = "checkout";
        };
        ignores = [
          ".DS_Store"
          "*.sublime-workspace"
          ".sublime/"
        ];
        extraConfig = {
          push.autoSetupRemote = true;
        };
      };

      programs.direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };
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
