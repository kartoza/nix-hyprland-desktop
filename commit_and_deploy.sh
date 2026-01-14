#!/usr/bin/env bash

set -e

# Ensure SSH agent is running and key is loaded
if [ -z "$SSH_AUTH_SOCK" ] || ! ssh-add -l > /dev/null 2>&1; then
    eval "$(ssh-agent -s)"
    ssh-add
fi

# Commit and push changes in current repo
echo "==> Committing changes in nix-hyprland-desktop..."
git add -A
git commit -m "${1:-Update hyprland-desktop configuration}"
git push

# Update flake in nix-config and rebuild
echo "==> Updating hyprland-desktop flake in nix-config..."
pushd ../nix-config > /dev/null
nix flake update hyprland-desktop

echo "==> Running rebuild..."
./utils/rebuild.sh
popd > /dev/null

echo "==> Done!"
