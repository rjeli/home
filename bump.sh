#!/usr/bin/env bash
set -euo pipefail

c_rst='\033[0m'
c_bld='\033[1;97m'

here="$(dirname "$(readlink -f "$0")")"
cd "$here"

echo -e "${c_bld} === Updating bumped.lock === ${c_rst}"

rm -f bumped.lock
nix flake update --output-lock-file bumped.lock

cfg=".#darwinConfigurations.$(hostname -s).system"

echo -e "${c_bld} === Building new configuration === ${c_rst}"

new=$(nix build --reference-lock-file bumped.lock --no-link --print-out-paths $cfg)

echo "new config path: $new"

diff=$(nix store diff-closures /run/current-system $new)

echo "$(tput smul)$(tput setaf 2) === Added === $(tput sgr 0)"
echo "$diff" | awk '/∅ →/{print "  " $0}'

echo "$(tput smul)$(tput setaf 1) === Removed === $(tput sgr 0)"
echo "$diff" | awk '/→ ∅/{print "  " $0}'

echo "$(tput smul)$(tput setaf 6) === Upgraded === $(tput sgr 0)"
echo "$diff" | awk '/^[^∅]+$/{print "  " $0}'

echo
echo "To accept these changes, \`mv bumped.lock flake.lock\` and then \`switch\`."