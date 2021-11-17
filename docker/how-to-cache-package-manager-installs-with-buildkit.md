# How to cache package manager installs with buildkit

Downloading project dependencies for every `Docker` rebuild is slow.  `buildkit` enables caching downloads locally between builds thus skipping this download.  Lifesaver.

`apt`:

```Dockerfile
# g++, unixodbc-dev for compiling pyodbc
# python3-dev, default-libmysqlclient-dev, build-essential for compiling MySQL
RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    apt-get update && apt-get install -y \
    g++ \
    python3-dev \
    build-essential
```

`poetry`:

```Dockerfile
COPY pyproject.toml poetry.lock /app/
COPY wheels/ /app/wheels/
RUN --mount=type=cache,target=/root/.cache \
    poetry install --no-dev --no-interaction
```

> See [moby/buildkit](https://github.com/moby/buildkit)