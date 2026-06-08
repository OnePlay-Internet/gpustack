#!/usr/bin/env bash
# STEP 2 — Show what is stored in MySQL right now.
# Run it before AND after recreating the container to compare.
# Run:  ./2-check-data.sh

# shellcheck source=/dev/null
source "$(dirname "$0")/common.sh"
need_docker

say "Tables in the gpustack database"
mysql_q "SHOW TABLES;"

say "Users"
mysql_q "SELECT id, username FROM users;"

say "Row counts (your data lives here)"
mysql_q "SELECT 'users' AS tbl, COUNT(*) FROM users
         UNION ALL SELECT 'models', COUNT(*) FROM models
         UNION ALL SELECT 'api_keys', COUNT(*) FROM api_keys;"
