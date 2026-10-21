#!/usr/bin/env bash
set -u

prefix="${LOOKLOOK_PREFIX:-/usr/local/lib/looklook}"
program="$prefix/looklook"
backup="${LOOKLOOK_BACKUP_DIR:-/var/lib/looklook-backup}"
image_backup="/usr/local/share/looklook-backup"

copy_tree() {
  local source="$1"
  [ -x "$source/looklook" ] || return 1
  mkdir -p "$backup"
  find "$backup" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
  cp -a "$source/." "$backup/"
}

restore_tree() {
  if [ -x "$backup/looklook" ]; then
    mkdir -p "$prefix"
    cp -a "$backup/." "$prefix/"
  elif [ -x "$image_backup/looklook" ]; then
    mkdir -p "$prefix"
    cp -a "$image_backup/." "$prefix/"
    copy_tree "$prefix" || true
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
      copy_tree "$prefix" || true
      last="$current"
    fi
  fi
  sleep "${LOOKLOOK_BACKUP_INTERVAL:-30}"
done
