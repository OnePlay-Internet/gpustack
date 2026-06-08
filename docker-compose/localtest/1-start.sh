#!/usr/bin/env bash
# STEP 1 — Start everything: MySQL + Grafana + GPUStack.
# Run:  ./1-start.sh

# shellcheck source=/dev/null
source "$(dirname "$0")/common.sh"
need_docker

say "Starting MySQL, Grafana, GPUStack"
$DC up -d

say "Waiting for GPUStack to answer on http://localhost"
# Try for ~2 minutes. curl returns non-zero until the server is ready.
for i in $(seq 1 60); do
  if curl -fsS -o /dev/null http://localhost; then
    ok "GPUStack is up"
    break
  fi
  echo "  ...waiting ($i)"
  sleep 2
done

say "Done"
echo "Open:    http://localhost      (login admin / admin)"
echo "Grafana: http://localhost:3000 (login admin / grafana)"
echo "Next:    create some data in the UI, then run ./2-check-data.sh"
