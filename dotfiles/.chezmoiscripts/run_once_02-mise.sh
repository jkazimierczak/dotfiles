#!/usr/bin/env bash

set -eu

if command -v mise &> /dev/null; then
  echo "Mise is already installed"
else
  echo "Installing mise"
  curl https://mise.run | sh
fi
