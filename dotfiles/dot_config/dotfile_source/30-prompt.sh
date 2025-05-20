#!/usr/bin/env bash

if [[ ! $(command -v oh-my-posh) ]]; then
  echo "Installing Oh My Posh..."
  curl -s https://ohmyposh.dev/install.sh | bash -s >/dev/null 2>&1
fi

# Use shell specific variables instead of $SHELL
# as $SHELL indicates the login shell, not the current shell
if [ -n "$ZSH_VERSION" ]; then
  eval "$(oh-my-posh init zsh)"
elif [ -n "$BASH_VERSION" ]; then
  eval "$(oh-my-posh init bash)"
fi
