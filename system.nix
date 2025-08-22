{ }:
{
  # how to modify power settings (minutes until sleep?)
  defaults = {
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
    NSGlobalDomain = {
      NSAutomaticCapitalizationEnabled = false;
      NSWindowShouldDragOnGesture = true;
    };
    WindowManager = {
      EnableTiledWindowMargins = false;
      EnableTilingByEdgeDrag = true;
      EnableTopTilingByEdgeDrag = false;
    };
    CustomSystemPreferences."com.apple.AdLib" = {
      allowApplePersonalizedAdvertising = false;
      allowIdentifierForAdvertising = false;
      forceLimitAdTracking = true;
      personalizedAdsMigrated = false;
    };
    CustomUserPreferences."org.hammerspoon.Hammerspoon".MJConfigFile = "~/.config/hammerspoon/init.lua";
  };

  keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };
}
