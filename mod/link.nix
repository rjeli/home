{
  pkgs,
  repo,
  ...
}:
{
  home-manager.sharedModules = [
    (
      { config, ... }:
      {
        home.file = (
          let
            inherit (builtins) listToAttrs;
            inherit (pkgs.lib.path) removePrefix;
            inherit (pkgs.lib.filesystem) listFilesRecursive;
            inherit (config.lib.file) mkOutOfStoreSymlink;

            linkDir = ../link;

            pathToAttr = (
              absPath:
              let
                relToHome = removePrefix linkDir absPath;
                relToHere = removePrefix ../. absPath;
              in
              {
                name = relToHome;
                value = {
                  source = mkOutOfStoreSymlink "${repo}/${relToHere}";
                };
              }
            );

            linkedFiles = (map pathToAttr (listFilesRecursive linkDir));

          in
          (listToAttrs linkedFiles)
        );
      }
    )
  ];
}
