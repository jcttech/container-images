#!/usr/bin/env bash
# Smoke-test that a postgres-agentic image actually exposes pg_trgm, vector
# and age. Used by CI after build, and runnable locally:
#
#   ./databases/postgres/agentic/verify.sh ghcr.io/jcttech/postgres-agentic:18
set -euo pipefail

image="${1:?usage: verify.sh <image>}"

echo "==> Checking extension files are present in image"
docker run --rm --entrypoint bash "$image" -c '
  set -e
  for f in \
      /usr/lib/postgresql/18/lib/vector.so \
      /usr/lib/postgresql/18/lib/age.so \
      /usr/share/postgresql/18/extension/vector.control \
      /usr/share/postgresql/18/extension/age.control \
      /usr/share/postgresql/18/extension/pg_trgm.control; do
    test -e "$f" || { echo "MISSING: $f"; exit 1; }
    echo "ok: $f"
  done
'

echo
echo "==> Starting an ephemeral postgres and loading extensions"
docker run --rm --user 26 --entrypoint bash "$image" -c '
  set -e
  export PATH=/usr/lib/postgresql/18/bin:$PATH
  data=$(mktemp -d)
  log=$(mktemp)
  initdb -D "$data" --auth=trust --username=postgres > /dev/null
  pg_ctl -D "$data" -l "$log" -o "-c listen_addresses=" -w start

  psql -U postgres -d postgres -v ON_ERROR_STOP=1 <<SQL
CREATE EXTENSION pg_trgm;
CREATE EXTENSION vector;
CREATE EXTENSION age;
LOAD '"'"'age'"'"';
SELECT extname, extversion FROM pg_extension
  WHERE extname IN ('"'"'pg_trgm'"'"','"'"'vector'"'"','"'"'age'"'"')
  ORDER BY extname;
SQL

  pg_ctl -D "$data" stop -m fast > /dev/null
'

echo
echo "==> postgres-agentic image $image looks good"
