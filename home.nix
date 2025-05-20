{
  here,
  pkgs,
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
        switch = "sudo darwin-rebuild switch --flake ${here}";
        history = "history 0";
        nixsh = "nix-shell --run 'exec zsh' -p";
        subl = "'/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl'";
        code = "$HOME/Applications/'Visual Studio Code.app'/Contents/Resources/app/bin/code";
        zed = "zeditor";
      };
      # added to .zshrc
      initContent = "source ${here}/.zshrc";
    };

    git = {
      enable = true;
      userName = "rjeli";
      userEmail = "eli@rje.li";
      aliases = {
        s = "status";
        co = "checkout";
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
    };

    sessionPath = [
      "${here}/bin"
      "/opt/homebrew/bin"
      "$HOME/bin"
      "$HOME/.cargo/bin"
      "$HOME/.deno/bin"
      "$HOME/.pnpm"
      "$HOME/.juliaup/bin"
    ];

    packages =
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
        cmake
        imagemagick

        # PaaS

        runpodctl
        flyctl

        # editors

        neovim
        vscodium
        zed-editor

        # languages

        nil
        nixd
        nixfmt-rfc-style
        nodejs
        pnpm
        uv
        deno
        dhall
        dhall-docs
        dhall-json
        dhall-lsp-server
        # julia
        # octaveFull
        sage
        typst
        zig

        # apps

        dbeaver-bin
        sqlitebrowser
        # jadx
        # mpv
        spotify
        stats
        discord

        mpv
        # transmission_4-gtk

        # latex

        texlive.combined.scheme-full

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
      in
      listToAttrs (
        map (
          p:
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
  };

}
