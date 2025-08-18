{
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking.hostName = "vega";

  services = {
    openssh.enable = true;
    tailscale = {
      enable = true;
      permitCertUid = "caddy";
    };
    caddy = {
      enable = true;
      virtualHosts."vega.kamori-matrix.ts.net".extraConfig = ''
        respond "hi vega.kamori-matrix.ts.net"
      '';
      virtualHosts."n8n.ts.rje.li".extraConfig = ''
        respond "hi n8n.ts.rje.li"
      '';
    };
  };

  environment.systemPackages = with pkgs; [
    curl
    git
    neofetch
    jujutsu

    # caddy
    n8n
    tmux
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICO2JNZm1v5StHEfUkv/LQboiAO6wbjB+nJs9hRfjutX eli@rje.li"
  ];

  system.stateVersion = "24.05";

  nixpkgs.config.allowUnfree = true;
}
