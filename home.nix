{
  here,
  pkgs,
  # pkgs-stable,
  config,
}:
{

  programs = {
    zsh = {
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
        # switch = "sudo darwin-rebuild switch --flake ${here} && rehash";
        switch = "nh darwin switch --ask && rehash";
        history = "history 0";
        nixsh = "nix-shell --run 'exec zsh' -p";
        subl = "'/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl'";
        code = "$HOME/Applications/'Visual Studio Code.app'/Contents/Resources/app/bin/code";
        # zed = "zeditor";
        zed = "/Applications/Zed.app/Contents/MacOS/cli";
        nix-tree-home = "nix-tree --derivation \"path:${here}#darwinConfigurations.$(hostname -s).system\"";
        rot13 = "tr 'A-Za-z' 'N-ZA-Mn-za-m'";
      };
      # added to .zshrc
      initContent = "source ${here}/.zshrc";
    };

    # fish = {
    #   enable = true;
    #   # plugins = with pkgs.fishPlugins; [
    #   #   # tide
    #   # ];
    # };

    git = {
      enable = true;
      userName = "rjeli";
      userEmail = "eli@rje.li";
      aliases = {
        s = "status";
        co = "checkout";
        aa = "add -A";
        cam = "commit -am";
        l = "log --graph --decorate --pretty=oneline --abbrev-commit";
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
        init.defaultBranch = "master";
        sendemail = {
          smtpserver = "smtp.fastmail.com";
          smtpuser = "eli@rje.li";
          smtpencryption = "ssl";
          smtpserverport = "465";
        };
      };
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };

  home = {
    stateVersion = "24.05";

    sessionVariables = {
      EDITOR = "vim";
      PNPM_HOME = "$HOME/.pnpm";

      NH_DARWIN_FLAKE = "${here}";
    };

    sessionPath = [
      "${here}/bin"
      # "/opt/homebrew/bin"
      "$HOME/bin"
      "$HOME/.local/bin"
      "$HOME/.cargo/bin"
      "$HOME/.deno/bin"
      "$HOME/.pnpm"
      "$HOME/.juliaup/bin"
      "$HOME/.ghcup/bin"
      "$HOME/.cabal/bin"
      "$HOME/.elan/bin"
      "/Applications/Postgres.app/Contents/Versions/latest/bin"
    ];

    packages =
      (with pkgs; [

        # tools for the cli itself
        devenv
        nushell
        nix-tree
        ripgrep
        jq
        pv
        fish

        jujutsu
        jjui

        # cli tools
        kubectl
        nmap
        picocom
        httpie
        ffmpeg
        imagemagick
        jujutsu
        socat
        yt-dlp
        zim-tools
        samply
        wget
        pandoc
        rsync
        # nh

        # build tools
        pkg-config
        cmake
        ninja
        ccache
        cocoapods
        just
        sccache
        gn

        # cli api wrappers
        gh

        # PaaS
        runpodctl
        flyctl

        # editors
        neovim
        vscodium
        # zed-editor

        # languages
        nil
        nixd
        nixfmt-rfc-style
        nodejs
        pnpm
        uv
        python3
        # deno
        dhall
        dhall-docs
        dhall-json
        dhall-lsp-server
        idris2
        # julia
        # octaveFull

        jdk
        # jdt-language-server

        # sage
        typst
        zig

        # gui apps
        dbeaver-bin
        sqlitebrowser
        # jadx
        # mpv
        # spotify
        stats
        # discord
        # mpv
        # transmission_4-gtk
        # blender
        xquartz

        # latex

        # texlive.combined.scheme-full

        # guh

        ollama

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

    file = (
      let
        inherit (builtins) listToAttrs;
        inherit (pkgs.lib.path) removePrefix;
        inherit (pkgs.lib.filesystem) listFilesRecursive;
        inherit (config.lib.file) mkOutOfStoreSymlink;

        pathToAttr = (
          absPath:
          let
            relToHome = removePrefix ./link absPath;
            relToHere = removePrefix ./. absPath;
          in
          {
            name = relToHome;
            value = {
              source = mkOutOfStoreSymlink "${here}/${relToHere}";
            };
          }
        );

        linkedFiles = (map pathToAttr (listFilesRecursive ./link));

      in

      (listToAttrs linkedFiles)
      /*
        // {
          "Library/Containers/com.userscripts.macos.Userscripts-Extension/Data/Documents/scripts" = {
            source = mkOutOfStoreSymlink "${here}/user.js";
          };
        }
      */
    );
  };

}
