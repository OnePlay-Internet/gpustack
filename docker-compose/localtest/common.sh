#!/usr/bin/env bash
# Shared settings + helpers for all test scripts.
# Every other script does:  source "$(dirname "$0")/common.sh"

set -euo pipefail   # stop on first error, treat unset vars as errors

# --- Where things are -------------------------------------------------------
# Folder that holds the compose file (one level up from this scripts folder).
COMPOSE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_FILE="$COMPOSE_DIR/docker-compose.localtest.yaml"

# Fixed project name => predictable container + volume names.
PROJECT="gpustacktest"

# One variable used everywhere instead of typing the long command each time.
# shellcheck disable=SC2034  # used by scripts that source this file
DC="docker compose -p $PROJECT -f $COMPOSE_FILE"

# --- Helpers ----------------------------------------------------------------
say()  { echo -e "\n=== $* ==="; }          # section header
ok()   { echo "  [OK] $*"; }
fail() { echo "  [FAIL] $*"; exit 1; }

# Run a SQL command inside the mysql container and print the result.
mysql_q() {
  docker exec "${PROJECT}-mysql" \
    mysql -ugpustack -pgpustack_pass gpustack -N -e "$1" 2>/dev/null
}

# Die early with a clear message if Docker is not reachable.
need_docker() {
  if ! docker ps >/dev/null 2>&1; then
    echo "Docker daemon not reachable."
    echo "Start Docker Desktop and enable WSL integration for this distro, then retry."
    exit 1
  fi
}
