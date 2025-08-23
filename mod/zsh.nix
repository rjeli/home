{ repo, ... }:
{
  home-manager.sharedModules = [
    {
      programs.zsh = {
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
          switch = "nh darwin switch --ask && rehash";
          history = "history 0";
          nixsh = "nix-shell --run 'exec zsh' -p";
          subl = "'/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl'";
          code = "$HOME/Applications/'Visual Studio Code.app'/Contents/Resources/app/bin/code";
          # zed = "zeditor";
          zed = "/Applications/Zed.app/Contents/MacOS/cli";
          nix-tree-home = "nix-tree --derivation \"path:${repo}#darwinConfigurations.$(hostname -s).system\"";
          rot13 = "tr 'A-Za-z' 'N-ZA-Mn-za-m'";
        };
        # added to .zshrc
        initContent = "source ${repo}/.zshrc";
      };
    }
  ];
}
