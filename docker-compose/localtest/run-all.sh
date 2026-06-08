#!/usr/bin/env bash
# ALL-IN-ONE automated test. No manual UI needed.
# It: starts everything -> records data -> recreates fresh GPUStack ->
# records data again -> compares. Prints PASS or FAIL.
# Run:  ./run-all.sh

# shellcheck source=/dev/null
source "$(dirname "$0")/common.sh"
need_docker

# 1) Start
say "1/5 Start stack"
$DC up -d
for _ in $(seq 1 60); do curl -fsS -o /dev/null http://localhost && break; sleep 2; done

# 2) Snapshot data BEFORE (GPUStack auto-creates the admin user + tables on first boot)
say "2/5 Record data BEFORE recreate"
BEFORE="$(mysql_q "SELECT COUNT(*) FROM users;")"
TABLES_BEFORE="$(mysql_q "SHOW TABLES;" | wc -l)"
echo "  users=$BEFORE  tables=$TABLES_BEFORE"
[ "${BEFORE:-0}" -ge 1 ] || fail "no users found before test - first boot did not seed DB"

# 3) Kill + wipe GPUStack container & its volume, keep MySQL
say "3/5 Recreate GPUStack from scratch (DB untouched)"
$DC rm -sf gpustack-server
docker volume rm "${PROJECT}_gpustack-data" 2>/dev/null || true
$DC up -d gpustack-server
for _ in $(seq 1 60); do curl -fsS -o /dev/null http://localhost && break; sleep 2; done

# 4) Snapshot data AFTER
say "4/5 Record data AFTER recreate"
AFTER="$(mysql_q "SELECT COUNT(*) FROM users;")"
TABLES_AFTER="$(mysql_q "SHOW TABLES;" | wc -l)"
echo "  users=$AFTER  tables=$TABLES_AFTER"

# 5) Compare + check the fresh container did not crash
say "5/5 Result"
CRASH="$(docker logs "${PROJECT}-gpustack-server" 2>&1 | grep -iE "traceback|fatal|cannot connect|access denied" | head -3 || true)"

if [ "$BEFORE" = "$AFTER" ] && [ "$TABLES_BEFORE" = "$TABLES_AFTER" ] && [ -z "$CRASH" ]; then
  ok "Data identical before/after ($AFTER users, $TABLES_AFTER tables)"
  ok "No crash in fresh container logs"
  echo -e "\n  PASS — fresh container reused existing data, no data loss, no crash."
else
  echo "  before: users=$BEFORE tables=$TABLES_BEFORE"
  echo "  after:  users=$AFTER tables=$TABLES_AFTER"
  [ -n "$CRASH" ] && printf '  crash signs:\n%s\n' "$CRASH"
  fail "FAIL — see numbers above."
fi
