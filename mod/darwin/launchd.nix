{ pkgs, user, ... }:
{
  launchd.user.agents = {
    userscript_server = {
      # command = "/Users/${user}/repos/home/bin/userscript_server";
      command = "${pkgs.deno}/bin/deno run -A /Users/${user}/repos/home/bin/userscript_server";

      serviceConfig = {
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "/tmp/userscript_server.out.log";
        StandardErrorPath = "/tmp/userscript_server.err.log";
      };
    };
  };
}
