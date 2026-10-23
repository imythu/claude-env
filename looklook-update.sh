#!/usr/bin/env bash
set -u

prefix="${LOOKLOOK_PREFIX:-/usr/local/lib/looklook}"
interval="${LOOKLOOK_UPDATE_INTERVAL:-3600}"

while :; do
  (
    exec 9>/tmp/looklook-update.lock
    flock -x 9
    LOOKLOOK_PREFIX="$prefix" LOOKLOOK_CONTAINER=1 \
      curl -fsSL https://looklook.dev/install.sh | \
      LOOKLOOK_PREFIX="$prefix" LOOKLOOK_CONTAINER=1 sh
  ) >/tmp/looklook-upgrade.log 2>&1 || true
  sleep "$interval"
done
