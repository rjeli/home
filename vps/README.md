install:

```sh
nix run github:nix-community/nixos-anywhere -- \
  --generate-hardware-config nixos-generate-config ./hardware-configuration.nix \
  --flake .#digitalocean \
  --target-host "root@167.99.225.60"
```

apply changes:

```sh
nixos-rebuild switch --flake .#digitalocean --target-host "root@167.99.225.60"
```
