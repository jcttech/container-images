# syntax=docker/dockerfile:1.7
#
# postgres-agentic — PostgreSQL 18 with pgvector, Apache AGE, and pg_trgm
# baked into the CloudNativePG operand image.
#
# Extensions:
#   - pg_trgm           (PostgreSQL contrib, ships with operand)
#   - pgvector 0.8.2    (copied from pgvector/pgvector:0.8.2-pg18-trixie)
#   - Apache AGE 1.7.0  (copied from apache/age:release_PG18_1.7.0)
#
# All three source images target PostgreSQL 18 on Debian Trixie, so the
# extension shared libraries are ABI-compatible with the operand's PG18
# build.
#
# Build:
#   docker build -t ghcr.io/jcttech/postgres-agentic:18 \
#                -f databases/postgres/agentic/Dockerfile .
#
# Use as a CloudNativePG operand:
#   apiVersion: postgresql.cnpg.io/v1
#   kind: Cluster
#   spec:
#     imageName: ghcr.io/jcttech/postgres-agentic:18
#
# Use stand-alone (e.g. local dev / integration tests):
#   docker run --rm -e POSTGRES_PASSWORD=test -p 5432:5432 \
#     ghcr.io/jcttech/postgres-agentic:18

# ---------------------------------------------------------------------------
# Stage 1: pgvector source
# ---------------------------------------------------------------------------
FROM pgvector/pgvector:0.8.2-pg18-trixie AS pgvector-source

# ---------------------------------------------------------------------------
# Stage 2: Apache AGE source
# ---------------------------------------------------------------------------
FROM apache/age:release_PG18_1.7.0 AS age-source

# ---------------------------------------------------------------------------
# Stage 3: Final image — CloudNativePG operand for PG18 with extensions
#
# Pinning to the Trixie variant so glibc matches the pgvector/AGE source
# images (both Trixie-based). The default `:18` tag is Bullseye and would
# fail to load vector.so at runtime with GLIBC_2.38 not found.
# ---------------------------------------------------------------------------
FROM ghcr.io/cloudnative-pg/postgresql:18-system-trixie

LABEL org.opencontainers.image.title="postgres-agentic"
LABEL org.opencontainers.image.description="PostgreSQL 18 + pgvector + Apache AGE + pg_trgm on the CloudNativePG operand"
LABEL org.opencontainers.image.source="https://github.com/jcttech/container-images"
LABEL org.opencontainers.image.licenses="Apache-2.0"

USER root

# --- pgvector --------------------------------------------------------------
COPY --from=pgvector-source /usr/lib/postgresql/18/lib/vector.so \
                            /usr/lib/postgresql/18/lib/
COPY --from=pgvector-source /usr/lib/postgresql/18/lib/bitcode/vector.index.bc \
                            /usr/lib/postgresql/18/lib/bitcode/
COPY --from=pgvector-source /usr/lib/postgresql/18/lib/bitcode/vector/ \
                            /usr/lib/postgresql/18/lib/bitcode/vector/
COPY --from=pgvector-source /usr/share/postgresql/18/extension/vector.control \
                            /usr/share/postgresql/18/extension/
COPY --from=pgvector-source /usr/share/postgresql/18/extension/vector--*.sql \
                            /usr/share/postgresql/18/extension/

# --- Apache AGE ------------------------------------------------------------
COPY --from=age-source /usr/lib/postgresql/18/lib/age.so \
                       /usr/lib/postgresql/18/lib/
COPY --from=age-source /usr/share/postgresql/18/extension/age.control \
                       /usr/share/postgresql/18/extension/
COPY --from=age-source /usr/share/postgresql/18/extension/age--*.sql \
                       /usr/share/postgresql/18/extension/

USER 26
