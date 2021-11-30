# How to switch selenium user within a test

I want to set up and tear down a `Selenium` `webdriver` twice in the same test so that I can test how my `Django` app behaves for multiple users.  By default `Selenium` hangs if the test function `test_multiple_users_can_start_lists_at_different_urls` fails at any point beyond quitting and restarting the `browser` ...

```python
import re
import socket
import time

import pytest
from pytest_django.live_server_helper import LiveServer
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities


def _get_remote_webdriver() -> webdriver.Remote:
    return webdriver.Remote(
        command_executor="http://selenium:4444/wd/hub",
        desired_capabilities=DesiredCapabilities.CHROME,
    )


@pytest.fixture
def webdriver_init() -> webdriver.Remote:
    browser = _get_remote_webdriver()
    yield browser
    browser.quit()


def _get_web_container_ipaddess() -> str:
    host_name = socket.gethostname()
    host_ipaddress = socket.gethostbyname(host_name)
    return host_ipaddress


@pytest.fixture
def live_server_at_web_container_ipaddress() -> LiveServer:
    # Set host to externally accessible web server address
    web_container_ip_address = _get_web_container_ipaddess()
    return LiveServer(addr=web_container_ip_address)


@pytest.mark.django_db
def test_multiple_users_can_start_lists_at_different_urls(
    webdriver_init: webdriver.Remote,
    live_server_at_web_container_ipaddress: LiveServer,
) -> None:
    browser = webdriver_init
    live_server_url = str(live_server_at_web_container_ipaddress)

    # Edith starts a new to-do list
    browser.get(live_server_url)
    inputbox = browser.find_element_by_id("id_new_item")
    inputbox.send_keys("Buy peacock feathers")
    inputbox.send_keys(Keys.ENTER)
    wait_for_row_in_list_table(browser, "1: Buy peacock feathers")

    # She notices that her list has a unique URL
    edith_list_url = browser.current_url
    assert re.search(
        "/lists/.+", edith_list_url
    ), f"Regex didn't match: 'lists/.+' not found in {edith_list_url}"

    # Now a new user, Francis, comes along to the site.

    ## We use a new browser session to make sure that no information
    ## of Edith's is coming through from cookies etc
    browser.quit()
    browser = _get_remote_webdriver()

    # Francis visits the home page. There is no sign of Edith's
    # list
    browser.get(live_server_url)
    page_text = browser.find_element_by_tag_name("body").text
    assert "Buy peacock feathers" not in page_text
    assert "make a fly" not in page_text

    # Francis starts a list by entering a new item. He
    # is less interesting than Edith...
    inputbox = browser.find_element_by_id("id_new_item")
    inputbox.send_keys("Buy milk")
    inputbox.send_keys(Keys.ENTER)
    wait_for_row_in_list_table(browser, "1: Buy milk")

    # Francis gets his own unique URL
    francis_list_url = browser.current_url
    assert re.search(
        "/lists/.+", francis_list_url
    ), f"Regex didn't match: 'lists/.+' not found in {francis_list_url}"
    assert francis_list_url != edith_list_url

    # Again, there is no trace of Edith's list
    page_text = browser.find_element_by_tag_name("body").text
    assert "Buy peacock feathers" not in page_text
    assert "Buy milk" in page_text

    # Satisfied, they both go back to sleep
```

I added a `breakpoint` after `yield` in `webdriver_init` ...

```python-traceback
> /app/functional_tests/tests.py(34)webdriver_init()
-> browser.quit()
(Pdb) browser.quit()
*** selenium.common.exceptions.WebDriverException: Message: Unable to execute request for an existing session: Unable to find session with ID: 0b215f3be5545e376c41ba5d1695e6d6
Build info: version: '4.1.0', revision: '87802e897b'
System info: host: 'f9d7fe69645a', ip: '172.18.0.2', os.name: 'Linux', os.arch: 'amd64', os.version: '5.10.60.1-microsoft-standard-WSL2', java.version: '11.0.11'
Driver info: driver.version: unknown
```

... which seems to fail because the 2nd browser session is created with a different `session_id` to the 1st browser session and so `Selenium` cannot quit a browser session which is already over.  I'm hacking around this by replacing ...

```python
    ...
    browser.quit()
    browser = _get_remote_webdriver()
    ...
```

... with ...

```python
    ...
    browser.delete_all_cookies()
    ...
```