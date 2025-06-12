{ }:
{
  enable = true;
  global.autoUpdate = false;
  onActivation.cleanup = "zap";
  taps = [ ];
  brews = [
    "mas"
  ];
  casks = [
    "alt-tab"
    "alfred"
    "claude"
    "discord"
    "eloston-chromium"
    "ghostty"
    "iterm2"
    "jan"
    "obsidian"
    "orbstack"
    "mpv"
    "spotify"
    "transmission"
    "xquartz"
    # in nix as zed-editor, but there are soo many updates
    "zed"
    "zotero"
  ];
  # `mas list | awk '{print $2, "=", $1, ";"}'`
  masApps = {
    Amphetamine = 937984704;
    DaisyDisk = 411643860;
    GarageBand = 682658836;
    Hyperduck = 6444667067;
    iMovie = 408981434;
    Keynote = 409183694;
    Numbers = 409203825;
    Obsidian = 6720708363;
    Pages = 409201541;
    SingleFile = 6444322545;
    SponsorBlock = 1573461917;
    Tailscale = 1475387142;
    Userscripts = 1463298887;
    Wipr = 1662217862;
    Xcode = 497799835;
  };
}
