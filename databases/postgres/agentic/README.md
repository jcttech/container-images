# postgres-agentic

PostgreSQL 18 image with the extension set used by agentic / memory-style
workloads, baked into the [CloudNativePG](https://cloudnative-pg.io/)
operand image (`ghcr.io/cloudnative-pg/postgresql:18-system-trixie`) so it
can be used directly as a CNPG `imageName`. The Trixie variant is required
so glibc matches the pgvector / AGE source images.

## Extensions

| Extension       | Version | Source                                            |
| --------------- | ------- | ------------------------------------------------- |
| `pg_trgm`       | contrib | CNPG operand                                      |
| `vector`        | 0.8.2   | `pgvector/pgvector:0.8.2-pg18-trixie`             |
| `age`           | 1.7.0   | `apache/age:release_PG18_1.7.0`                   |

All three source images target PostgreSQL 18 on Debian Trixie, so the
shared libraries are ABI-compatible with the operand's PG18 build.

## Image tags

Published to `ghcr.io/jcttech/postgres-agentic`:

- `:18` — pinned to PostgreSQL 18.
- `:latest` — same as the most recent `:18` build.

## Usage

### As a CNPG operand

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: example
spec:
  instances: 3
  imageName: ghcr.io/jcttech/postgres-agentic:18
```

### Stand-alone

```bash
docker run --rm -e POSTGRES_PASSWORD=test -p 5432:5432 \
  ghcr.io/jcttech/postgres-agentic:18
```

Then load the extensions:

```sql
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS age;
LOAD 'age';
```

## Build locally

```bash
docker build \
  -t ghcr.io/jcttech/postgres-agentic:18 \
  -f databases/postgres/agentic/Dockerfile \
  .
```

Then smoke-test the extensions:

```bash
./databases/postgres/agentic/verify.sh ghcr.io/jcttech/postgres-agentic:18
```

## CI

Built and published by
[`.github/workflows/build-postgres-agentic.yml`](../../../.github/workflows/build-postgres-agentic.yml).
The workflow uses the shared `jcttech/.github/.github/actions/docker-build`
composite for tag-conventions + push, with a local pre-push verify so a
broken extension build never lands on the registry.
