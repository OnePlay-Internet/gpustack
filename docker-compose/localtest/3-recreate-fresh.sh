#!/usr/bin/env bash
# STEP 3 — The real test.
# Delete the GPUStack container AND wipe its local volume (simulate a fully
# fresh container). MySQL + Grafana are left untouched, so the DATA stays.
# Then start a brand-new GPUStack that reconnects to the same MySQL.
# Run:  ./3-recreate-fresh.sh

# shellcheck source=/dev/null
source "$(dirname "$0")/common.sh"
need_docker

say "Removing GPUStack container + its cache volume (DB is NOT touched)"
$DC rm -sf gpustack-server
docker volume rm "${PROJECT}_gpustack-data" 2>/dev/null && ok "cache volume wiped" \
  || echo "  (cache volume already gone)"

say "Starting a fresh GPUStack against the existing MySQL"
$DC up -d gpustack-server

say "Waiting for the fresh container to come up"
for i in $(seq 1 60); do
  if curl -fsS -o /dev/null http://localhost; then
    ok "Fresh GPUStack is up"
    break
  fi
  echo "  ...waiting ($i)"
  sleep 2
done

say "Now run ./2-check-data.sh again — data must match what you had before"
