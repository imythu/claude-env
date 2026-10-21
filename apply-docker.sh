#!/usr/bin/env bash
# Run fuck-claude's Linux repair script inside the container.
# The container job always uses --force so a previous state file does not
# prevent the scheduled repair from running again.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${SCRIPT_DIR}/apply-linux.sh" --force "$@"
