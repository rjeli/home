{
  modulesPath,
  pkgs,
  ...
}:
{
  nix = {
    channel.enable = false;
    settings = {
      experimental-features = "nix-command flakes pipe-operators";
      accept-flake-config = true;
    };
  };

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
      useRoutingFeatures = "both";
      extraSetFlags = [
        "--advertise-exit-node"
        "--advertise-connector"
      ];
      # permitCertUid = "caddy";
    };
    # caddy = {
    #   enable = true;
    #   virtualHosts."vega.kamori-matrix.ts.net".extraConfig = ''
    #     respond "hi vega.kamori-matrix.ts.net"
    #   '';
    #   virtualHosts."n8n.ts.rje.li".extraConfig = ''
    #     reverse_proxy localhost:5678
    #   '';
    # };
  };

  # systemd.services.n8n = {
  #   description = "n8n";
  #   after = [ "network.target" ];
  #   wantedBy = [ "multi-user.target" ];
  #   environment = {
  #     N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS = "true";
  #     N8N_RUNNERS_ENABLED = "true";
  #   };
  #   serviceConfig = {
  #     Type = "simple";
  #     ExecStart = "${pkgs.n8n}/bin/n8n";
  #     Restart = "on-failure";
  #     User = "n8n";
  #     Group = "n8n";
  #     WorkingDirectory = "/var/lib/n8n";
  #     StateDirectory = "n8n";
  #   };
  # };

  users = {
    # users.n8n = {
    #   isSystemUser = true;
    #   group = "n8n";
    #   home = "/var/lib/n8n";
    #   createHome = true;
    # };
    # groups.n8n = { };

    users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICO2JNZm1v5StHEfUkv/LQboiAO6wbjB+nJs9hRfjutX eli@rje.li"
    ];
  };

  environment.systemPackages = with pkgs; [
    curl
    git
    neofetch
    jujutsu
    nh

    # caddy
    # n8n
    tmux
  ];

  system.stateVersion = "24.05";

  nixpkgs.config.allowUnfree = true;

  virtualisation.oci-containers = {
    containers = {
      n8n = {
        image = "docker.n8n.io/n8nio/n8n";
        ports = [ "5678:5678" ];
        volumes = [ "n8n_data:/home/node/.n8n" ];
        environment = {
          N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS = "true";
          N8N_RUNNERS_ENABLED = "true";
          NODE_FUNCTION_ALLOW_BUILTIN = "true";
          NODE_FUNCTION_ALLOW_EXTERNAL = "true";
          GENERIC_TIMEZONE = "America/New_York";
          TZ = "America/New_York";
          TESTVAR = "test";
        };
      };
    };
  };
}
