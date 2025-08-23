{
  home-manager.sharedModules = [
    {
      programs.git = {
        enable = true;
        userName = "rjeli";
        userEmail = "eli@rje.li";
        aliases = {
          s = "status";
          co = "checkout";
          aa = "add -A";
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
          sendemail = {
            smtpserver = "smtp.fastmail.com";
            smtpuser = "eli@rje.li";
            smtpencryption = "ssl";
            smtpserverport = "465";
          };
        };
      };
    }
  ];
}
