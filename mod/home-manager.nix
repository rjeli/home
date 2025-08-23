{ user, here, ... }:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    verbose = true;
    backupFileExtension = "bak";
    extraSpecialArgs = { inherit here; };
    users.${user} = {
      imports = [ ../home.nix ];
    };
  };
}
