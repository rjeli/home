{ user, ... }:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    verbose = true;
    backupFileExtension = "bak";
    extraSpecialArgs = { };
    users.${user} = {
      # imports = [ ../home.nix ];
    };
  };
}
