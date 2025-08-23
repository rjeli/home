{
  self,
  nh,
  user,
  platform,
  ...
}:
{
  system = {
    configurationRevision = self.rev or self.dirtyRev or null;
    stateVersion = 5;
    primaryUser = user;
  };

  users.users.${user} = {
    name = user;
    home = "/Users/${user}";
  };

  programs.zsh.enable = true;
  security.pam.services.sudo_local.touchIdAuth = true;

  environment.systemPackages = [
    # pull this from stable so it doesnt take ages to build
    # todo its broken on 25.05. https://github.com/nixos/nixpkgs/issues/421014
    # pkgs-stable.texlive.combined.scheme-full
    nh.packages.${platform}.default
  ];
}
