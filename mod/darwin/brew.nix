{
  config,
  user,
  nix-homebrew,
  homebrew-core,
  homebrew-cask,
  ...
}:
{
  imports = [
    nix-homebrew.darwinModules.nix-homebrew
  ];

  nix-homebrew = {
    enable = true;
    user = user;
    taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
    };
    mutableTaps = false;
    autoMigrate = true;
    extraEnv = {
      HOMEBREW_NO_ANALYTICS = "1";
    };
  };

  homebrew = {
    enable = true;
    taps = builtins.attrNames config.nix-homebrew.taps;
    global.autoUpdate = false;
    onActivation = {
      cleanup = "zap";
      extraFlags = [ "--verbose" ];
    };
    casks = [
      "alt-tab"
      "alfred"
      "claude"
      "discord"
      "ghostty"
      "iterm2"
      "jan"
      "obsidian"
      "orbstack"
      "postgres-unofficial" # postgres.app
      "stolendata-mpv"
      "spotify"
      "transmission"
      "ungoogled-chromium"
      # "xquartz"
      "zed" # in nix as zed-editor, but there are soo many updates
      "zotero"
    ];
  };

  # for diffing
  environment.etc."Brewfile".text = config.homebrew.brewfile;
}
