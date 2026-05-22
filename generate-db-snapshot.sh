#!/bin/bash
# Generates a NetBox core DB snapshot (no plugins) for use as a CI test baseline.
# Run this at each major NetBox release and commit the resulting file in db-snapshots/.

echo "▶️ $0 $*"

_RED=$(tput setaf 1)
_GREEN=$(tput setaf 2)
_CYAN=$(tput setaf 6)
_CLEAR=$(tput sgr0)

set -euo pipefail

set -a
source netbox_version.env
source env/postgres.env
set +a

mkdir -p db-snapshots

SNAPSHOT_FILE="db-snapshots/netbox-${NETBOX_VER}-core.sql.gz"

if [ -f "$SNAPSHOT_FILE" ]; then
  echo "${_RED}WARNING: $SNAPSHOT_FILE already exists. Overwriting.${_CLEAR}"
fi

echo "${_GREEN}INFO: Generating core DB snapshot for NetBox ${NETBOX_VER} (plugins disabled)${_CLEAR}"

teardown() {
  docker compose -f docker-compose.test.yml -f docker-compose.snapshot.yml down -v
}
trap teardown EXIT

docker compose \
  -f docker-compose.test.yml \
  -f docker-compose.snapshot.yml \
  up -d --build --wait --wait-timeout 900


echo "${_CYAN}DEBUG: Dumping database...${_CLEAR}"

docker compose -f docker-compose.test.yml -f docker-compose.snapshot.yml \
  exec -T \
  -e PGPASSWORD="${POSTGRES_PASSWORD}" \
  postgres \
  pg_dump \
  --username="${POSTGRES_USER}" \
  --dbname="${POSTGRES_DB}" \
  --no-owner \
  --no-acl \
  | gzip > "${SNAPSHOT_FILE}"

echo "${_GREEN}INFO: Snapshot saved to ${SNAPSHOT_FILE} ($(du -h "${SNAPSHOT_FILE}" | cut -f1))${_CLEAR}"

teardown
