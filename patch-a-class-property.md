I have a `Django` model with a class property called `credentials` like ...

```python
from django.db import models


class RemoteFilesystemSpec(models.Model):
    name = models.CharField(max_length=100, blank=False, null=False, unique=True)
    protocol = models.CharField(max_length=100)
    host = models.CharField(max_length=100)
    port = models.IntegerField()
    username = models.CharField(max_length=100)
    password = models.CharField(max_length=100)
    secret_key = models.FileField(upload_to="secret_key", blank=True)

    @property
    def credentials(self) -> typing.Dict[str, str]:
        key_filename = {"key_filename": self.secret_key.file.name} if self.secret_key else {}
        return {
            "host": self.host,
            "port": self.port,
            "username": self.username,
            "password": self.password,
            **key_filename
        }

    def __str__(self) -> str:
        return f"{self.host} | {self.station}"
```

... and I want to mock out `credentials` so that I can run tests against `LocalFileSystem` via `fsspec` instead of `SFTPFileSystem` which is used in practice.

I can use `Python` builtin `patch` to mock out this property!

```python
from unittest.mock import patch

from upload.models import RemoteFilesystemSpec


@patch("upload.models.RemoteFilesystemSpec.credentials", property(lambda self: {}))
@pytest.mark.django_db
def test_copy_new_files_across_remotes() -> None:
    source_spec = RemoteFilesystemSpec(
        name="",
        protocol="",
        host="",
        port=0,
        username="",
        password="",
        secret_key=None
    )
    print(source_spec.credentials)
    # ...
```

> https://stackoverflow.com/questions/42704506/how-to-mock-a-property