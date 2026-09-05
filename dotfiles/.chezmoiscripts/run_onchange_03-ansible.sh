#!/usr/bin/env bash
# tools/ansible-latest/uv.lock hash: {{ include "tools/ansible-latest/uv.lock" | sha256sum }}

_installOrUpdate() {
  ansible_version=$1

  if [[ ! -d "${HOME}/tools/${ansible_version}" ]]; then
    echo "Ansible not found, installing Ansible"
    exit 1
  fi

  pushd "${HOME}/tools/${ansible_version}" &>/dev/null || exit
  uv sync

  echo "${ansible_version} installed successfully"

  if [[ $? -ne 0 ]]; then
    echo "Failed to uv sync Ansible venv in ${ansible_version}"
    exit 1
  fi

  popd &>/dev/null || exit
}

_setupAnsible() {
  echo ""
  echo "--- Verify Ansible installation ---"

  _installOrUpdate "ansible-latest"
}

_setupAnsible
exit 0
