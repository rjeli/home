# home

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

## cold install: (untested)

start with xcode from mac app store

then:

- [install lix](https://lix.systems/install/#on-any-other-linuxmacos-system)
- install brew
- switch

```zsh
% curl -sSf -L https://install.lix.systems/lix | sh -s -- install
% /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
% nix run nix-darwin/master#darwin-rebuild -- switch --flake .
```

probably also want rustup

```zsh
% curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```


inspo:
- https://github.com/davish/setup
