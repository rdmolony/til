# How to mock out requesting a file from an external website

I'm developing a `streamlit` web application that requests a 1GB zip file from an external website, unzips it, cleans it, zips it and returns this new file to the user upon request.  I want to mock out the call to this external website to encapsulate my functional & unit tests as it would be very inefficient to have to download this file on every test run.

I first need to create a file `BERPublicsearch.txt` within a zip archive `BERPublicsearch.zip` ...

```python
@pytest.fixture
def sample_bers(tmp_path: Path) -> BytesIO:
    bers = pd.read_csv("sample-BERPublicsearch.txt", sep="\t")
    f = bers.to_csv(index=False, sep="\t")
    filepath = tmp_path / "BERPublicsearch.zip"
    with ZipFile(filepath, "w") as zf:
        zf.writestr("BERPublicsearch.txt", f)
    return ZipFile(filepath).read("BERPublicsearch.txt")
```

... where `sample-BERPublicsearch.txt` is a 100 row sample of the data set saved in source control and `sample_bers` returns a bytes representation of the zip file.

I can now use the `responses` library to mock a request to the SEAI website and return this sample zip file ...

```python
from io import BytesIO
import json
from pathlib import Path
from time import sleep
from zipfile import ZipFile

import pandas as pd
import pytest
import responses
from selenium import webdriver
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities


with open("defaults.json") as f:
    DEFAULTS = json.load(f)


@responses.activate
def test_user_can_download_default_bers(
    ..., sample_bers: BytesIO
) -> None:
    responses.add(
        responses.POST,
        DEFAULTS["download"]["url"],
        body=sample_bers,
        content_type="application/x-zip-compressed",
        headers={
            "content-disposition": "attachment; filename=BERPublicSearch.zip"
        },
        status=200,
    )
```

... where all POST request arguments are saved in `defaults.json`.  

This could be improved by using `pytest` fixtures to encapsulate this logic in a function that could be called by any test to mock out this call to SEAI thus avoiding some duplication.

#pytest
