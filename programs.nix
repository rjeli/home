{ here }:
{

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
      switch = "darwin-rebuild switch --flake ${here}";
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

}
