#!/usr/bin/env bash

set -eu

echo "Installing mise"

if command -v mise &> /dev/null; then
  echo "Mise is installed"
else
  curl https://mise.run | sh
  # mkdir -p ${HOME}/.config/zsh
  # ${HOME}/.local/bin/mise activate zsh > ${HOME}/.config/zsh/mise.zsh
fi
