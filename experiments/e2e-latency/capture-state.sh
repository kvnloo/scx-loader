#!/usr/bin/env bash
set -u

out="${1:-scx-state-$(date +%Y%m%d-%H%M%S).txt}"

run() {
  printf '\n$ %s\n' "$*"
  "$@" 2>&1 || true
}

{
  printf 'captured_at='
  date --iso-8601=seconds
  run git rev-parse HEAD
  run uname -a
  run cat /etc/os-release
  run cat /sys/kernel/sched_ext/state
  run sh -c 'cat /sys/kernel/sched_ext/*/ops 2>/dev/null'
  run scxctl status
  run systemctl status scx_loader.service --no-pager
  run systemctl status power-profiles-daemon.service --no-pager
  run journalctl -u scx_loader.service -n 200 --no-pager
  run journalctl -k -n 300 --no-pager
} > "$out"

printf 'wrote %s\n' "$out"
