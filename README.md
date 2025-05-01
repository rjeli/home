format: 

```zsh
% nix-shell -p nixfmt-rfc-style --run 'nixfmt flake.nix'
```

bump nix packages:

```zsh
% ./bump.sh
```

bump homebrew:

(todo: figure out how to lock brew packages into git)

```zsh
% brew update
% brew outdated
% brew upgrade
```

gc:

```zsh
% nix store gc
# todo: --dry-run seems to do nothing
```

cold install: (untested)

- [install lix](https://lix.systems/install/#on-any-other-linuxmacos-system)
- install brew
- switch

```zsh
% curl -sSf -L https://install.lix.systems/lix | sh -s -- install
% /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
% nix run nix-darwin/master#darwin-rebuild -- switch --flake .
```


inspo:
- https://github.com/davish/setup
