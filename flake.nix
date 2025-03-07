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
      nixpkgs.config.allowUnfree = true;

      system.configurationRevision = self.rev or self.dirtyRev or null;
      # backcompat: read `darwin-rebuild changelog` before changing
      # todo:             ^ broken
      system.stateVersion = 5;

      # services.nix-daemon.enable = true;

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
        taps = [
        ];
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
          "xquartz"
          "zotero"
          # "ra3xdh/qucs-s/qucs-s@nightly"
        ];
      };

      security.pam.services.sudo_local.touchIdAuth = true;
    };

    homeConfig = { pkgs, config, ... }: {
      home.stateVersion = "24.05";

      home.sessionVariables = {
        EDITOR = "vim";
        PNPM_HOME = "$HOME/.pnpm";
      };
      home.sessionPath = [
        "${self}/bin"
        "/opt/homebrew/bin"
        "$HOME/bin"
        "$HOME/.cargo/bin"
        "$HOME/.deno/bin"
        "$HOME/.pnpm"
      ];

      home.packages = (with pkgs; [ 
        # tools
        devenv
        ffmpeg
        jq
        nmap
        picocom
        pkg-config
        # radare2
        ripgrep

        # editors
        neovim
        vscodium

        # libs
        # qt5.qtbase qt5.qttools

        # languages
        nodejs
        pnpm

        uv

        deno 
        dhall dhall-docs dhall-json dhall-lsp-server
        # octaveFull
        (sage.override { requireSageTests = false; })

        # apps
        # jadx
        mpv
        spotify

        # blender
        # (octaveFull.withPackages (opkgs: with opkgs; [ ltfat ]))
        # (octave.withPackages (opkgs: with opkgs; [ symbolic splines ]))
        # octavePackages.ltfat
        # ((octave.override { enableQt = true; }).withPackages (opkgs: with opkgs; [ ltfat ]))
      ]) ++ [
      /* insecure
        (let emacs = (pkgs.emacs29-macport.override {
          withTreeSitter = true; }); in (pkgs.emacsPackagesFor
          emacs).emacsWithPackages (epkgs: with epkgs; [
          treesit-grammars.with-all-grammars ])) 
          */
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
          nixsh = "nix-shell --run 'exec zsh' -p";
          subl = "'/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl'";
          code = "$HOME/Applications/'Visual Studio Code.app'/Contents/Resources/app/bin/code";
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
          ".envrc"
          ".direnv"
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
