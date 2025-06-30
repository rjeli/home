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
(seems impossible. brew pure rolling release lol)

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

tree:
```zsh
% nix-tree --derivation '.#darwinConfigurations.rj-m4.system'
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

setup xquartz

```zsh
~ % xquartz-install
Warning: Expecting a LaunchDaemons path since the command was ran as root. Got LaunchAgents instead.
`launchctl bootstrap` is a recommended alternative.
```

todo: hmm ^

inspo:
- https://github.com/davish/setup

# todo:

system settings:
- power mgmt
- unbind ⌘-Spc from spotlight, bind to alfred

find stats alternative?

unfuck mpv

update bump.sh - should put diff in git commit message.
