#!/usr/bin/env bash

# Syncs the flake into /etc/nixos for local copy and automatic upgrades.
# Omits secrets of other hosts
# Aborts if
# - this host has no host-specific config
# - /etc/nixos is a symlink

set -euo pipefail

src="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
host="$(hostname)"

# Abort unless flake contains config for this host.
if ! grep -q "nixosConfigurations.$host" "$src/nixos/systems/$host.nix" 2>/dev/null; then
    echo "error: '$host' is not a host targeted by this config" >&2
    exit 1
fi

# Abort if /etc/nixos is a symlink.
if [[ -L /etc/nixos ]]; then
    echo "error: /etc/nixos is a symlink to $(readlink -f /etc/nixos)" >&2
    exit 1
fi

echo "Promoting $src -> /etc/nixos (host: $host)"

sudo rsync --archive --delete --delete-excluded --info=stats1 \
    --chown=root:root --chmod=D755,F644 \
    --include="/secrets/hosts/$host/***" --exclude='/secrets/hosts/*' \
    --include="/secrets/rekeyed/$host/***" --exclude='/secrets/rekeyed/*' \
    --exclude='.git' --exclude='.direnv' --exclude='.claude' \
    --exclude='.stfolder' --exclude='.stignore' \
    --exclude='result*' --exclude='*.img*' --exclude='*.iso' \
    "$src/" /etc/nixos/

echo
echo "Done. Next: cd /etc/nixos && nh os switch . --ask"
