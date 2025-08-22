{
  homebrew = {
    enable = true;
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
      # "jan"
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
}
