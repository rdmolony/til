I setup an action to test pull requests & pushes to the `main` branch ([[Cache docker compose images via github actions]]).  This action saves all system dependencies to an image & volume mounts the source code to it.  This means that caching across workflow runs is simple and fast.  It takes roughly 30 seconds instead to setup the environment instead of ~5 minutes. 

I then wanted a separate action to deploy updated source code (i.e. pushes to `main`) to `Docker Hub` where it can be accessed by `Azure Web App` to rebuild our production web app.       

Amazingly `bake-action` is able to use the cached image layers from the `tests.yml` action to build the image!  The only difference between this action and `tests.yml` is that we use `poetry install --no-dev` for production, and we copy the source code across into the image.

The only blocker was adapting `bake-action` to save images at their `git` commit SHA (a unique identifier).  `bake-action` `set` doesn't work with environment variables if the environment variables themselves consists of environment variables -

```yml
env:

  IMAGE_NAME: rdmolony/stationmanager-dev:${{ github.sha }}
 

jobs:


  build:


    runs-on: ubuntu-latest


    steps:

	  ...
      
	  - name: Build

        uses: docker/bake-action@v2.0.0

        with:

          push: false

          load: true

          set: |

            web.cache-from=type=gha

            web.cache-to=type=gha

            web.tags=${{ env.IMAGE_NAME }}
```

I can instead define an image name using the `git` commit SHA in compose -

```yml
      - name: Build

        uses: docker/bake-action@v2.0.0

        env:

          TARGET: production

          IMAGE_NAME: rdmolony/stationmanager:${{ github.sha }}

        with:

          push: true

          set: |

            web.cache-from=type=gha
```

```yml
services:

  web:

    environment:

      - TARGET

      - IMAGE_NAME

    build:

      context: .

      target: $TARGET

    image: $IMAGE_NAME
```

#github-actions 
#docker 
#docker-compose 