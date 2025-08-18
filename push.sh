set -euo pipefail

sync() {
    rsync \
        --archive \
        --compress \
        --mkpath \
        --delete --recursive --force \
        --delete-excluded \
        --delete-missing-args \
        --human-readable \
        --delay-updates \
        "$@"
}

here="$(dirname "$(readlink -f "$0")")"
host="$1"

dst="repos/home"

echo "here is $here"
echo "host is $host"
echo "dst is $dst"

# ssh -tt "$host" "rm -rf $dst"

git ls-files | sync --files-from - "$here" "$host:$dst"

ssh -tt "$host" "nixos-rebuild switch --flake /root/repos/home#$host"
