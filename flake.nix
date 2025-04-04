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

  outputs =

    inputs@{
      self,
      nixpkgs,
      darwin,
      home-manager,
    }:

    let

      darwinConfig =
        { pkgs, ... }:
        {
          nixpkgs.hostPlatform = "aarch64-darwin";
          nixpkgs.config.allowUnfree = true;

          system.configurationRevision = self.rev or self.dirtyRev or null;
          # backcompat: read `darwin-rebuild changelog` before changing
          # todo:             ^ broken
          system.stateVersion = 5;

          # need newer nix for flake relative paths
          nix.package = pkgs.nixVersions.nix_2_26;
          nix.settings = {
            experimental-features = "nix-command flakes";
          };

          # todo figure out how to not hardcode?
          # https://github.com/nix-community/home-manager/issues/4026
          users.users.eriggs = {
            name = "eriggs";
            home = "/Users/eriggs";
          };

          programs.zsh.enable = true;

          environment.systemPackages = with pkgs; [ ];

          system.defaults = {
            dock.autohide = true;
            trackpad.Clicking = true;
            finder = {
              AppleShowAllFiles = true; # show hidden
              AppleShowAllExtensions = true;
              ShowPathbar = true;
              FXPreferredViewStyle = "Nlsv"; # list view
              FXEnableExtensionChangeWarning = false;
              _FXShowPosixPathInTitle = true;
              CreateDesktop = false; # no icons on desktop
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
            taps = [ ];
            brews = [ "zenity" ];
            casks = [
              "ghostty"
              "iterm2"
              "alt-tab"
              "eloston-chromium"
              "xquartz"
              "zotero"
              "docker"
            ];
          };

          security.pam.services.sudo_local.touchIdAuth = true;
        };

      homeConfig =
        { pkgs, config, ... }:

        let
          here = "${config.home.homeDirectory}/repos/home";

        in
        {
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

          home.packages =
            (with pkgs; [

              # cli tools

              devenv
              ffmpeg
              jq
              kubectl
              nmap
              picocom
              pkg-config
              ripgrep
              httpie

              runpodctl

              # editors

              neovim
              vscodium

              # languages

              nodejs
              pnpm

              uv

              deno
              dhall
              dhall-docs
              dhall-json
              dhall-lsp-server
              # octaveFull
              (sage.override { requireSageTests = false; })

              # apps

              dbeaver-bin
              sqlitebrowser
              # jadx
              # mpv
              spotify

              # blender
              # (octaveFull.withPackages (opkgs: with opkgs; [ ltfat ]))
              # (octave.withPackages (opkgs: with opkgs; [ symbolic splines ]))
              # octavePackages.ltfat
              # ((octave.override { enableQt = true; }).withPackages (opkgs: with opkgs; [ ltfat ]))

            ])
            ++ [
              /*
                insecure
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
              switch = "darwin-rebuild switch --flake ${here}";
              history = "history 0";
              nixsh = "nix-shell --run 'exec zsh' -p";
              subl = "'/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl'";
              code = "$HOME/Applications/'Visual Studio Code.app'/Contents/Resources/app/bin/code";
            };
            # added to .zshrc
            initExtra = (builtins.readFile ./.zshrc);
          };

          home.file = (
            let
              inherit (builtins) listToAttrs;
              inherit (pkgs.lib.path) removePrefix;
              inherit (pkgs.lib.filesystem) listFilesRecursive;
            in
            listToAttrs (
              map (p:
                let
                  relToHome = removePrefix ./link p;
                  relToHere = removePrefix ./. p;
                in 
                {
                  name = relToHome;
                  value = {
                    source = config.lib.file.mkOutOfStoreSymlink "${here}/${relToHere}";
                  };
                }
              ) (listFilesRecursive ./link)
            )
          );

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
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.verbose = true;
            home-manager.users.eriggs = homeConfig;
          }
        ];
      };
    };

}
