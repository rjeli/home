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

```zsh
% nix run nix-darwin/master#darwin-rebuild -- switch
```


inspo:
- https://github.com/davish/setup
