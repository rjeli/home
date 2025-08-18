#!/usr/bin/env bash
set -euo pipefail

c_rst='\033[0m'
c_bld='\033[1;97m'

hdr() {
    echo -e "${c_bld} === $1 === ${c_rst}"
}

here="$(dirname "$(readlink -f "$0")")"
cd "$here"

hdr "Updating bumped.lock"

rm -f bumped.lock
nix flake update --output-lock-file bumped.lock

cfg=".#darwinConfigurations.$(hostname -s).system"

hdr "Building new configuration"

new=$(nix build --reference-lock-file bumped.lock --no-link --print-out-paths $cfg)

hdr "New config path: $new"

diff=$(nix store diff-closures /run/current-system $new)

echo "$(tput smul)$(tput setaf 2) === Added === $(tput sgr 0)"
echo "$diff" | awk '/∅ →/{print "  " $0}'

echo "$(tput smul)$(tput setaf 1) === Removed === $(tput sgr 0)"
echo "$diff" | awk '/→ ∅/{print "  " $0}'

echo "$(tput smul)$(tput setaf 6) === Upgraded === $(tput sgr 0)"
echo "$diff" | awk '/^[^∅]+$/{print "  " $0}'

echo
echo "To accept these changes, \`mv bumped.lock flake.lock\` and then \`switch\`."
