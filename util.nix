{ pkgs }:
{
  mkHomeFiles = (
    let
      inherit (builtins) listToAttrs;
      inherit (pkgs.lib.path) removePrefix;
      inherit (pkgs.lib.filesystem) listFilesRecursive;
      relFilePaths = map (removePrefix ./.) (listFilesRecursive ./link);
    in
      listToAttrs (map (p: { name = p; value = p; }) relFilePaths)
      
      # ".config/ghostty/config".source =  config.lib.file.mkOutOfStoreSymlink "${here}/config/ghostty";
  );
}


/*
let
  lib = pkgs.lib;
  inherit (builtins) readDir;

  findFiles =
    dir:
    lib.flatten (
      lib.mapAttrsToList (
        name: type: if type == "directory" then findFiles (dir + "/${name}") else dir + "/${name}"
      ) (builtins.readDir dir)
    );

in
{
  findFiles = findFiles;
}
*/