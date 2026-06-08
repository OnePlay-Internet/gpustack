# GPUStack on shared external infra

Run the whitelabel GPUStack container as a **consumer** of services shared with
your other projects. No data lives in the container — prune/recreate freely.

## What's shared

| Service | Wired via | Builtin disabled |
|---|---|---|
| MySQL / Postgres | `GPUSTACK_DATABASE_URL` | yes (skips embedded Postgres) |
| Grafana | `GPUSTACK_GRAFANA_URL` | yes |
| Prometheus | scrapes `gpustack:10161` | yes |
| Redis | n/a — GPUStack does not use Redis | — |

## Steps

1. **Remote DB** — on the MySQL host:
   ```bash
   sudo mysql < setup-mysql.sql
   # ensure bind-address = 0.0.0.0 in mysqld.cnf, then: sudo systemctl restart mysql
   ```
   Postgres alternative — create DB `gpustack` + user, set `DB_SCHEME=postgresql`, `DB_PORT=5432`.

2. **Shared Prometheus** — add jobs from `prometheus/gpustack-scrape.snippet.yml`
   (replace `GPUSTACK_HOST`), reload Prometheus.

3. **Shared Grafana** — point a datasource at the shared Prometheus. Import the
   GPUStack dashboards and match the UIDs in `.env` (`gpustack-worker`, `gpustack-model`).

4. **GPUStack**:
   ```bash
   cp .env.shared-infra.example .env   # edit IPs + creds
   docker compose -f docker-compose.shared-infra.yaml --env-file .env up -d
   ```

## Data safety

DB schema auto-created/migrated on first start (alembic, idempotent).
```bash
docker compose -f docker-compose.shared-infra.yaml down
docker volume rm docker-compose_gpustack-data   # wipe container state
docker compose -f docker-compose.shared-infra.yaml --env-file .env up -d  # reattaches same DB
```
Data persists because it lives in your remote DB, not the container.
