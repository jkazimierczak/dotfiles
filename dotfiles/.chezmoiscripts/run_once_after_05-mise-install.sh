#!/usr/bin/env bash 
# mise/config.toml hash: {{ include "dot_config/mise/config.toml" | sha256sum }}

set -eu

echo ""
echo "--- Install all mise tools ---"

${HOME}/.local/bin/mise install
