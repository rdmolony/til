I want to use `Buildkit` cache to save files downloaded via `wget`.

I can skip a downloading a file using `-nc`/`--no-clobber` to skip overwriting a file that already exists but I cannot use this alongside `-O`/`--output-document` if I want to specify the filename.  I also cannot use the more intelligent `-N`/`--timestamping` which also checks if the local version is newer than the remote version for the same reason.  I can, however, manually check a file exists with `test` ...

```bash
test -f /root/.wheels/basemap-1.2.2rel.tar.gz || \
    wget -O /root/.wheels/basemap-1.2.2rel.tar.gz https://github.com/matplotlib/basemap/archive/refs/tags/v1.2.2rel.tar.gz
```

Now to use this alongside `Buildkit` cache.  Mimicking package managers, I can save the file to `/root/.wheels` and copy it across ...


```Dockerfile
RUN --mount=type=cache,target=/root/.wheels \
    mkdir /app/wheels && \
    test -f /root/.wheels/basemap-1.2.2rel.tar.gz || \
    wget -O /root/.wheels/basemap-1.2.2rel.tar.gz https://github.com/matplotlib/basemap/archive/refs/tags/v1.2.2rel.tar.gz && \
    cp /root/.wheels/basemap-1.2.2rel.tar.gz /app/wheels/basemap-1.2.2rel.tar.gz
```

#docker