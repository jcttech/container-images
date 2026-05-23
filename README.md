# container-images

Shared container-image repo for jcttech usage.

Each subdirectory under a category builds and publishes an independent
image to `ghcr.io/jcttech/<family>-<variant>` via its own GitHub Actions
workflow under `.github/workflows/build-<family>-<variant>.yml`. The
workflows use the shared
[`jcttech/.github/.github/actions/docker-build@v1`](https://github.com/jcttech/.github/tree/main/.github/actions/docker-build)
composite for consistent tagging (`:sha`, `:latest` on `main`,
semver-from-tags) and only fire on changes to their own variant
directory, so adding a new image never disturbs the others.

## Naming convention

Folders are nested for grouping; image names and workflow names flatten
the same path with `-` so everything stays grep-friendly:

| Concept       | Pattern                                       | Example                                |
| ------------- | --------------------------------------------- | -------------------------------------- |
| Folder        | `<category>/<family>/<variant>/`              | `databases/postgres/agentic/`          |
| Image         | `ghcr.io/jcttech/<family>-<variant>`          | `ghcr.io/jcttech/postgres-agentic`     |
| Workflow file | `.github/workflows/build-<family>-<variant>.yml` | `build-postgres-agentic.yml`        |
| Workflow name | `build-<family>-<variant>`                    | `build-postgres-agentic`               |

The category (`databases`, eventually `runtimes`, `tools`, …) is only a
folder-level grouping — it isn't part of the image or workflow name,
since the family already disambiguates (`postgres-*`, `redis-*`, etc.).

## Layout

```
<category>/<family>/<variant>/
  Dockerfile
  README.md
  verify.sh        # optional smoke test, also run in CI
```

## Images

| Category    | Variant                                                       | Image                                  |
| ----------- | ------------------------------------------------------------- | -------------------------------------- |
| `databases` | [`postgres/agentic`](databases/postgres/agentic/)             | `ghcr.io/jcttech/postgres-agentic`     |

## Adding a new image

1. Create the variant directory (e.g. `databases/postgres/<variant>/`) with a `Dockerfile`, `README.md`, and optional `verify.sh`.
2. Add `.github/workflows/build-<family>-<variant>.yml`, modeled on the existing workflows — path-filtered to the new variant directory so its pipeline stays independent.
3. Register the new image in the table above.
