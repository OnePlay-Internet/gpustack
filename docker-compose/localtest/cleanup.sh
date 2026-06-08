#!/usr/bin/env bash
# Tear everything down. Pass --wipe to also delete the data volumes.
# Run:  ./cleanup.sh         (stop + remove containers, KEEP data)
#       ./cleanup.sh --wipe  (also delete MySQL + Grafana data)

# shellcheck source=/dev/null
source "$(dirname "$0")/common.sh"
need_docker

if [ "${1:-}" = "--wipe" ]; then
  say "Stopping and DELETING everything incl. data volumes"
  $DC down -v
  ok "all gone"
else
  say "Stopping and removing containers (data volumes kept)"
  $DC down
  ok "containers gone, data kept (run with --wipe to delete data)"
fi
