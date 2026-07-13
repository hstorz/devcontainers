#!/bin/bash
set -euo pipefail

# Dotfiles are applied from a PINNED commit of h1st0ry3D/dotfiles.
# Bump DOTFILES_COMMIT to update to the latest dotfiles.

DOTFILES_REPO="https://github.com/h1st0ry3D/dotfiles.git"
DOTFILES_COMMIT="a15e146"

echo "==> Applying dotfiles from chezmoi @ ${DOTFILES_COMMIT}..."
chezmoi init "${DOTFILES_REPO}" --no-tty
git -C "$(chezmoi source-path)" -c advice.detachedHead=false checkout "${DOTFILES_COMMIT}"
chezmoi apply --destination="${HOME}" --no-tty

echo "==> Configuring git to use hunk as the default diff viewer..."

git config --global core.pager "hunk pager"
git config --global diff.tool hunk
git config --global difftool.hunk.cmd 'hunk diff "$LOCAL" "$REMOTE"'
git config --global difftool.prompt false

echo "==> Dev container ready."
