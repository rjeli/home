{
  repo,
  repoSrc,
  lib,
  ...
}:
{
  home-manager.sharedModules = [
    (hm: {
      home.file = (
        let

          inherit (builtins) listToAttrs;
          inherit (lib.path) removePrefix;
          inherit (lib.filesystem) listFilesRecursive;
          inherit (hm.config.lib.file) mkOutOfStoreSymlink;

          linkDir = repoSrc + /link;

        in

        listFilesRecursive linkDir
        |> map (
          path:
          let
            relToHome = removePrefix linkDir path;
          in
          {
            name = relToHome;
            value = {
              source = mkOutOfStoreSymlink "${repo}/link/${relToHome}";
            };
          }
        )
        |> listToAttrs

      );
    })
  ];
}
