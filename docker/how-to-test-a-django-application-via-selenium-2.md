# How to test a django application via selenium 2

[Marc Gibbons blog](https://marcgibbons.com/post/selenium-in-docker/) provides a nice working example but it doesn't explain how it works in as much detail as I'd like.

Marc uses `Docker` `links` to enable referring to the `selenium` container using its name rather than its IP address ...

```yml
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
      - 4444:4444
      - 5900:5900
```

... which enables hooking into the `Selenium` `RemoteDriver` running elsewhere ...

```python
from selenium import webdriver
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities


browser = webdriver.Remote(
    command_executor='http://selenium:4444/wd/hub',
    desired_capabilities=DesiredCapabilities.CHROME,
)
```

For the following code ...

```python

@tag('selenium')
@override_settings(ALLOWED_HOSTS=['*'])
class BaseTestCase(StaticLiveServerTestCase):
    """
    Provides base test class which connects to the Docker
    container running selenium.
    """
    host = '0.0.0.0'

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.host = socket.gethostbyname(socket.gethostname())
        cls.selenium = webdriver.Remote(
            command_executor='http://selenium:4444/wd/hub',
            desired_capabilities=DesiredCapabilities.CHROME,
        )
        cls.selenium.implicitly_wait(5)
```

... `host` defines running a `StaticLiveServerTestCase` similar to `python manage.py runserver 0.0.0.0:8000`, and setting `cls.host` to `socket.gethostbyname(socket.gethostname())` only impacts `self.live_server_url` by replacing `0.0.0.0` with the docker container IP address.  This enables accessing the running `web` container from the `selenium` container.

I adapt this example to run on `pytest` instead of `unittest` via `pytest-django` at [rdmolony/django-selenium-pytest-docker](https://github.com/rdmolony/django-selenium-pytest-docker)

I struggled to adapt [Harry Percival's obeythetestinggoat examples](https://www.obeythetestinggoat.com/) initial functional test example.

In this case I want to run the `Selenium` `RemoteDriver` on a running `web` server (started via `python manage.py runserver 0.0.0.0:8000`).  To access this running server from the `Selenium` browser I created `http://{host}/8000` where host is `socket.gethostbyname(socket.gethostname())`.

`host` was `172.22.0.4` instead of `172.22.0.3`. It turns out that I was creating multiple shells in the `web` container incorrectly.  

I launched `web` via ...

```bash
docker compose run --name goat-web --rm web python manage.py runserver 0.0.0.0:8000
```

... and I hooked into this running server to run my functional tests via ...

```bash
docker compose run --rm web python functional_tests.py
```

... which is wrong!  Hooking into `web` creates a separate container with a separate IP address.  If instead I hook into the running server via `exec` instead of `run` it works fine ...

```bash
docker exec -it goat-web python functional_tests.py
```

> I got sidetracked reading into `Docker` networking.  It turns out that `Docker Compose` creates a network on `docker compose up` which means that `web` can access `selenium` via `http://selenium` instead of running its IP address and so does not need to be explicitely linked via `links`!