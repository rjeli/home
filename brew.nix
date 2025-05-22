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
    "eloston-chromium"
    "ghostty"
    "iterm2"
    "jan"
    "obsidian"
    "orbstack"
    "spotify"
    "transmission"
    "xquartz"
    "zotero"
  ];
  # `mas list | awk '{print $2, "=", $1, ";"}'`
  masApps = {
    Amphetamine = 937984704;
    DaisyDisk = 411643860;
    Hyperduck = 6444667067;
    Obsidian = 6720708363;
    SponsorBlock = 1573461917;
    Tailscale = 1475387142;
    Userscripts = 1463298887;
    Wipr = 1662217862;
    Xcode = 497799835;
  };
}
