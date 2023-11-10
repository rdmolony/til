# Test a django app on docker via selenium

Marc Gibbons guide [Selenium Tests in Django & Docker](https://marcgibbons.com/post/selenium-in-docker/) and [accompanying code](https://github.com/marcgibbons/django-selenium-docker) works like a charm on `Windows Subsystems for Linux 2 (WSL2)` except for the `VNC Viewer` which can't be installed on my work laptop without authorisation by IS.

> VNC means virtual network computing or remotely controlling a computer from anoter device

The key is `Docker Compose` [`links`](https://docs.docker.com/compose/compose-file/compose-file-v3/#links) ...

```yaml
version: '3'
services:
  django:
    build: .
    volumes:
      - ".:/code"
    links:
      - selenium
    ports:
      - "8000:8000"
  selenium:
    image: selenium/standalone-chrome-debug:3.7.1
    ports:
      - 4444:4444 # Selenium
      - 5900:5900 # VNC Server
```

... which links the `django` container to the `selenium` container which means that containers for the linked service are accessible at a hostname identical to the alias.

[`NoVNC`](https://github.com/novnc/noVNC) runs on `WSL2` without requiring admin priviledges.  It enables hooking into the `Selenium` `VNC` server.

First, I got `Selenium` running ...

```bash
docker compose start selenium
```

... which starts a `VNC Server` at `localhost:5900` which I can hook into with `NoVNC` by running the `novnc_proxy` `Shell` script ...

```bash
git clone https://github.com/novnc/noVNC
cd noVNC
./utils/novnc_proxy --vnc localhost:5900
```

... and access in my browser via `localhost:5900/vnc.html`.

I can now run my `Django` app unit tests and view their execution via `NoVNC` via ...

```bash
docker compose run django
python manage.py test
```

#docker