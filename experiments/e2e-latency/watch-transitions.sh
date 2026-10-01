#!/usr/bin/env bash
set -u

out="${1:-scx-transitions-$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$out"

cleanup() {
  if [[ -n "${journal_pid:-}" ]]; then
    kill "$journal_pid" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

journalctl -f --no-pager \
  -u scx_loader.service \
  -u power-profiles-daemon.service \
  > "$out/journal.txt" 2>&1 &
journal_pid=$!

snapshot() {
  local ts sched kernel_state kernel_ops profile
  ts="$(date --iso-8601=ns)"
  sched="$(scxctl get 2>&1 | tr '\n' ';' || true)"
  kernel_state="$(cat /sys/kernel/sched_ext/state 2>/dev/null || true)"
  kernel_ops="$(cat /sys/kernel/sched_ext/*/ops 2>/dev/null | tr '\n' ';' || true)"
  profile="$(powerprofilesctl get 2>/dev/null || true)"
  printf '%s|profile=%s|scxctl=%s|kernel_state=%s|ops=%s\n' \
    "$ts" "$profile" "$sched" "$kernel_state" "$kernel_ops"
}

last=""
echo "watching scheduler / power-profile transitions; Ctrl-C to stop"
echo "state log: $out/state.log"
echo "journal:   $out/journal.txt"

while :; do
  current="$(snapshot)"
  comparable="${current#*|}"
  if [[ "$comparable" != "$last" ]]; then
    printf '%s\n' "$current" | tee -a "$out/state.log"
    last="$comparable"
  fi
  sleep 0.25
done
