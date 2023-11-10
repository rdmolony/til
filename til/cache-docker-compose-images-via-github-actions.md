> **TLDR**
> As of 2022-06-23 both [docker/bake-action](https://github.com/docker/bake-action) or [satackey/action-docker-layer-caching](https://github.com/satackey/action-docker-layer-caching)are good options.  I had to hack around a little to use access the cached images in `docker compose` across multiple `GitHub Actions` steps.  See the relevant sections below for more information. 

## Context
I wanted to setup  `GitHub Actions` so that our test suite runs on all pull request or pushes to the `main` branch so that any changes don't break existing functionality.

Specifically, we use `docker compose` at `mainstreamrp-dev` to setup a development environment for our `Django` web app.  Our integration tests interact with `Selenium` (browser automation), `Microsoft SQL Server` & `MySQL` (databases) via `docker compose`.  To set it up `Docker` reads  a `Dockerfile` which specifies the system dependencies required to run the web app and stores the result in an image; we use `python-poetry` for `Python` and  `apt` for `Ubuntu`.  If any of these dependencies change we need to rebuild the image which can take several minutes.  If they don't change between test runs I'd rather not wait several minutes every time and use caching to access a prebuilt image.

As of 2022-06-23 setting up this caching was tricky.  

I created [rdmolony/cache-docker-compose-images](https://github.com/rdmolony/cache-docker-compose-images) to experiment with 3rd party packages to do this for me:
- [docker/build-push-action: GitHub Action to build and push Docker images with Buildx](https://github.com/docker/build-push-action) - not recommended for `docker compose`
- [docker/bake-action: GitHub Action to use Docker Buildx Bake as a high-level build command](https://github.com/docker/bake-action) - works
- [satackey/action-docker-layer-caching: 🐳 Enable Docker layer caching in GitHub Actions](https://github.com/satackey/action-docker-layer-caching) - works

Using these packages I was able to cache in one step, but I found it hard to access this cached image via `docker compose` in subsequent steps.

## [satackey/action-docker-layer-caching](https://github.com/satackey/action-docker-layer-caching) 

The [satackey/action-docker-layer-caching](https://github.com/satackey/action-docker-layer-caching) has good documentation.  On every new pull request or push the image is built from scratch & on subsequent runs of `GitHub Actions` the cache is used instead.

The only tricky thing was to invalidate the cache if the `Dockerfile` (or a `poetry.lock` file) changes so that we rebuild the image. After a little hunting, I found I could use the builtin function `hashFiles` to create a unique hash based on the  `Dockerfile` which I could pass via the `key` & `restore-keys` parameters to [satackey/action-docker-layer-caching](https://github.com/satackey/action-docker-layer-caching) to invalidate the cache if this file changes.

```yml
# This is a basic workflow to help you get started with Actions

  

name: CI

  

# Controls when the workflow will run

on:

# Triggers the workflow on push or pull request events but only for the "main" branch

push:

branches: [ "master" ]

pull_request:

branches: [ "master" ]

  

# Allows you to run this workflow manually from the Actions tab

workflow_dispatch:

  

env:

IMAGE_NAME: cache-docker-compose-images

  

# A workflow run is made up of one or more jobs that can run sequentially or in parallel

jobs:

# This workflow contains a single job called "build"

build:

# The type of runner that the job will run on

runs-on: ubuntu-latest

  

# Steps represent a sequence of tasks that will be executed as part of the job

steps:

# Checks-out your repository under $GITHUB_WORKSPACE, so your job can access it

- uses: actions/checkout@v3

  

- name: Login to Docker Hub

uses: docker/login-action@v2

with:

username: ${{ secrets.DOCKERHUB_USERNAME }}

password: ${{ secrets.DOCKERHUB_TOKEN }}

  

# Pull the latest image to build, and avoid caching pull-only images.

# (docker pull is faster than caching in most cases.)

- run: docker-compose pull

  

# In this step, this action saves a list of existing images,

# the cache is created without them in the post run.

# It also restores the cache if it exists.

- uses: satackey/action-docker-layer-caching@v0.0.11

# Ignore the failure of a step and avoid terminating the job.

continue-on-error: true

with:

key: ${{ runner.os }}-${{ github.workflow }}-${{ hashFiles('**/Dockerfile') }}-{hash}

restore-keys: |

${{ runner.os }}-${{ github.workflow }}-${{ hashFiles('**/Dockerfile') }}

- name: Test

run: docker compose run web

  

- name: Tag image

run: docker tag $IMAGE_NAME:latest ${{ secrets.DOCKERHUB_USERNAME }}/$IMAGE_NAME:$GITHUB_SHA

  

- name: Push image to Docker Hub

run: docker push ${{ secrets.DOCKERHUB_USERNAME }}/$IMAGE_NAME:$GITHUB_SHA
```

## [docker/bake-action](https://github.com/docker/bake-action) 
With the help of @crazy-max I worked out how to get `docker compose run` to play nicely with [docker/bake-action](https://github.com/docker/bake-action) 

> See [How to access the bake-action cached image in subsequent steps? · Issue #81 · docker/bake-action (github.com)](https://github.com/docker/bake-action/issues/81)

I needed to:
- Load environment variables  in a `.env` in `bash` in a step as this wasn't yet supported in [docker/bake-action](https://github.com/docker/bake-action) 
- Specify `load: true` for the `bake-action` to save the `Docker` image so that the runner can access it in subsequent steps
- Set the image name in `docker-compose.yml` to the same name as the  `bake-action` 

`ci.yml`:
```yml
# This is a basic workflow to help you get started with Actions

  

name: CI

  

# Controls when the workflow will run

on:

  # Triggers the workflow on push or pull request events but only for the "main" branch

  push:

    branches: [ "master" ]

  pull_request:

    branches: [ "master" ]

  

  # Allows you to run this workflow manually from the Actions tab

  workflow_dispatch:

  

env:

  IMAGE_NAME: rdmolony/web

  PUSH_TAG: ${{ github.sha }}

  

# A workflow run is made up of one or more jobs that can run sequentially or in parallel

jobs:

  # This workflow contains a single job called "build"

  build:

    # The type of runner that the job will run on

    runs-on: ubuntu-latest

  

    # Steps represent a sequence of tasks that will be executed as part of the job

    steps:

      # Checks-out your repository under $GITHUB_WORKSPACE, so your job can access it

      - uses: actions/checkout@v3

  

      # bake-action does not yet load .env

      - name: Export .env to GITHUB_ENV

        run: cat .env >> $GITHUB_ENV

  

      - name: Set up Docker Buildx

        uses: docker/setup-buildx-action@v2

  

      - name: Build

        uses: docker/bake-action@v2.0.0

        with:

          push: false

          load: true

          set: |

            web.cache-from=type=gha

            web.cache-to=type=gha

            web.tags=${{ env.IMAGE_NAME }}

      - name: Test

        run: docker compose run web
```

`docker-compose.yml`:
```yml
version: "3.7"

  

services:

  web:

    build:

      context: .

    image: rdmolony/web

    command: echo "Test run successful!"
```

> **Note**: `.env` must be loaded into `GITHUB_ENV` to use the variables across steps [Environment variables - GitHub Docs](https://docs.github.com/en/actions/learn-github-actions/environment-variables#passing-values-between-steps-and-jobs-in-a-workflow)

This action caches between workflow runs!  This means that I won't have to rebuild if the image hasn't changed on the first pull request or push.  I couldn't figure this out easily using [satackey/action-docker-layer-caching](https://github.com/satackey/action-docker-layer-caching) though I imagine it's possible provided the right hash key is used.

> See [Cache via bake action reuse by rdmolony · Pull Request #6 · rdmolony/cache-docker-compose-images (github.com)](https://github.com/rdmolony/cache-docker-compose-images/pull/6)

#github-actions
#docker
#docker-compose