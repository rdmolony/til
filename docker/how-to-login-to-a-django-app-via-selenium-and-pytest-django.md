# How to login to a django app via selenium and pytest django

I wanted to run end to end browser tests using `Selenium` and `pytest-django`.  I struggled to adapt [`marcgibbons/django-selenium-docker`](https://github.com/marcgibbons/django-selenium-docker) from `unittest` to `pytest`.  I couldn't authenticate the automatically authenticated user or `admin_user` generated by a `pytest-django` `pytest` fixture.

I was able to verify that `pytest-django` does in fact create an authenticated user by dropping a `breakpoint` into my functional test ...

```python
from django.contrib.auth import authenticate
from django.contrib.auth.models import User

@pytest.mark.django_db(transaction=True)
def test_manual_admin_user_login(
    live_server_url: str, browser: webdriver.Remote, admin_user: User
) -> None:
    breakpoint()
```

```python
>> User.objects.all()
>> authenticate(user="admin", password="password")
```

... so the issue wasn't `pytest-django` user creation.  I tried to manually login to the website as `@marcgibbons` does ...

```python
from urllib.parse import urlparse

from django.conf import Settings
from django.contrib.auth.models import User
import pytest
from pytest_django.live_server_helper import LiveServer
from selenium import webdriver
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities


@pytest.fixture(autouse=True)
def override_allowed_hosts(settings: Settings) -> None:
    settings.ALLOWED_HOSTS = ["*"]  # Disable ALLOW_HOSTS


@pytest.fixture
def live_server_url() -> str:
    # Set host to externally accessible web server address
    return str(LiveServer(addr="django"))


@pytest.fixture
def browser() -> webdriver.Remote:
    browser_ = webdriver.Remote(
        command_executor='http://selenium:4444/wd/hub',
        desired_capabilities=DesiredCapabilities.CHROME,
    )
    yield browser_
    browser_.quit()


@pytest.mark.django_db
def test_manual_admin_user_login(
    live_server_url: str, browser: webdriver.Remote, admin_user: User
) -> None:
    """
    As a superuser with valid credentials, I should gain
    access to the Django admin.
    """
    browser.get(live_server_url)

    username_input = browser.find_element_by_name('username')
    username_input.send_keys('admin')
    password_input = browser.find_element_by_name('password')
    password_input.send_keys('password')
    browser.find_element_by_xpath('//input[@value="Log in"]').click()

    path = urlparse(browser.current_url).path
    assert path == '/'

    body_text = browser.find_element_by_tag_name('body').text
    assert 'WELCOME, ADMIN.' in body_text
```

... this didn't work either.

I tried overriding my browser's cookies with the `admin_user` fixture credentials ...

> Adapted from `@aljosa` implementation in an issue on the `pytest-django` GitHub

```python
from urllib.parse import urlparse

from django.conf import settings
from django.conf import Settings
from django.test.client import Client
from django.contrib.auth.models import User
import pytest
from pytest_django.live_server_helper import LiveServer
from selenium import webdriver
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities


@pytest.fixture
def authenticated_browser(
    admin_client: Client, browser: webdriver.Remote, live_server_url: str
) -> webdriver.Remote:
    browser.get(live_server_url)
    sessionid = admin_client.cookies["sessionid"]
    cookie = {
        'name': settings.SESSION_COOKIE_NAME,
        'value': sessionid.value,
        'path': '/'
    }
    browser.add_cookie(cookie)
    browser.refresh()
    return browser


@pytest.mark.django_db
def test_auto_admin_user_login(
    live_server_url: str, authenticated_browser: webdriver.Remote, admin_user: User
) -> None:
    browser = authenticated_browser
    browser.get(live_server_url)

    path = urlparse(browser.current_url).path
    assert path == '/'

    body_text = browser.find_element_by_tag_name('body').text
    assert 'WELCOME, ADMIN.' in body_text
```

... this failed too!

It turns out that the user credentials must be stored in the `django` website database or else it won't be able to access them!  This means that we need to allow `pytest-django` to migrate the credentials into the test database in order to login via selenium.  I can just replace ...

```python
@pytest.mark.django_db
```

... with ...

```python
@pytest.mark.django_db(transaction=True)
```

... and I can login as expected