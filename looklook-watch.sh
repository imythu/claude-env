#!/usr/bin/env bash
set -u

prefix="${LOOKLOOK_PREFIX:-/opt/looklook}"
program="$prefix/looklook"
backup="${LOOKLOOK_BACKUP_DIR:-/var/lib/looklook-backup}"
image_backup="/usr/local/share/looklook-backup"

copy_binary() {
  local source="$1"
  [ -x "$source" ] || return 1
  mkdir -p "$backup"
  install -m 0755 "$source" "$backup/looklook"
}

restore_tree() {
  if [ -x "$backup/looklook" ]; then
    mkdir -p "$prefix"
    install -m 0755 "$backup/looklook" "$program"
  elif [ -x "$image_backup/looklook" ]; then
    mkdir -p "$prefix"
    install -m 0755 "$image_backup/looklook" "$program"
    copy_binary "$program" || true
  fi
}

mkdir -p "$backup"
if [ ! -x "$program" ]; then
  restore_tree
fi

last=""
while :; do
  if [ -x "$program" ]; then
    current=$(sha256sum "$program" 2>/dev/null | awk '{print $1}')
    if [ -n "$current" ] && [ "$current" != "$last" ]; then
      copy_binary "$program" || true
      last="$current"
    fi
  fi
  sleep "${LOOKLOOK_BACKUP_INTERVAL:-30}"
done
