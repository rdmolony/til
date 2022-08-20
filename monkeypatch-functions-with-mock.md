
I can use `Mock` to record calls & return a value in `pytest` if I want to replace a function ...

```python
from unittest import Mock

import fsspec


def test_foo(monkeypatch):
    monkeypatch.setattr(
        "stationmanager.tasks.fsspec.filesystem",
        Mock(return_value=fsspec.filesystem("file"))
    )
    ...
```

Specifically, I wanted to replace an `smb` based filesystem with a local filesystem for testing!

#python 
#pytest