{ pkgs, repo, ... }:
{
  home-manager.sharedModules = [
    {
      home.stateVersion = "24.05";

      home.sessionVariables = {
        EDITOR = "vim";
        PNPM_HOME = "$HOME/.pnpm";
        NH_DARWIN_FLAKE = "${repo}";
      };

      home.sessionPath = [
        "${repo}/bin"
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

      home.packages =
        (with pkgs; [

          # tools for the cli itself
          devenv
          nushell
          nix-tree
          ripgrep
          jq
          pv
          fish
          delta
          difftastic

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
    }
  ];
}
