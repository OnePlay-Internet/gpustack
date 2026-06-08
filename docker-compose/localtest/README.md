# GPUStack persistence test (local Docker)

Proves: **delete the GPUStack container, recreate it fresh → no data loss, no crash.**
Data lives in a local MySQL container; GPUStack is just a consumer.

## Prereqs
- Docker Desktop running, WSL integration ON for this distro (`docker ps` must work).

## Easiest: one command
```bash
cd docker-compose/localtest
chmod +x *.sh        # first time only
./run-all.sh         # does the whole test, prints PASS / FAIL
```

## Manual (see it with your own eyes)
```bash
./1-start.sh             # start MySQL + Grafana + GPUStack
# open http://localhost (admin/admin), create a user / api key / model
./2-check-data.sh        # note the numbers
./3-recreate-fresh.sh    # delete GPUStack + its volume, start a NEW one
./2-check-data.sh        # numbers must be identical -> data survived
```

## Clean up
```bash
./cleanup.sh             # remove containers, KEEP data
./cleanup.sh --wipe      # remove containers AND delete data volumes
```

## What each file does
| File | Job |
|---|---|
| `common.sh` | shared settings (compose file, project name, helpers) |
| `1-start.sh` | start the whole stack |
| `2-check-data.sh` | print tables + rows stored in MySQL |
| `3-recreate-fresh.sh` | delete GPUStack container + volume, recreate fresh |
| `run-all.sh` | automated start→recreate→compare, prints PASS/FAIL |
| `cleanup.sh` | tear down |

## Why it works
- `GPUSTACK_DATABASE_URL` points at the MySQL container → GPUStack skips its
  built-in Postgres (`gpustack/cmd/prerun.py:87`).
- Real data sits in the `mysql-data` Docker volume, not in GPUStack's volume.
- A fresh GPUStack runs migrations idempotently (Alembic version-tracked) and
  reuses existing tables — no wipe, no re-init.
```
```
