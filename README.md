
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

inspo:
- https://github.com/davish/setup
