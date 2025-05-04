{
  here,
  pkgs,
  config,
}:
{

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
      mas

      runpodctl

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
}
