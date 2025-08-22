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

            pathToAttr = (
              absPath:
              let
                relToHome = removePrefix ../link absPath;
                relToHere = removePrefix ./.. absPath;
              in
              {
                name = relToHome;
                value = {
                  source = mkOutOfStoreSymlink "${repo}/${relToHere}";
                };
              }
            );

            linkedFiles = (map pathToAttr (listFilesRecursive ../link));

          in

          (listToAttrs linkedFiles)

          /*
            // {
              "Library/Containers/com.userscripts.macos.Userscripts-Extension/Data/Documents/scripts" = {
                source = mkOutOfStoreSymlink "${here}/user.js";
              };
            }
          */
        );
      }
    )
  ];
}
