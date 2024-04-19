I want to test some `huey` tasks.  To do so I need to adapt them into `immediate` mode.  This is complicated by the fact that my tasks are created by decorating functions with `db_task` & `db_periodic_task` from `huey.contrib.djhuey`.  This means that these tasks read `settings.py` for `huey` configuration (see [here](https://github.com/coleifer/huey/blob/390925dcdad8f8057c7cbc98b565c213c9fad87a/huey/contrib/djhuey/__init__.py)), and as of 2022-07-05, it is not straightforward to override settings in `pytest-django`.

Ideally we should be able to do something like ...

```python
import pytest

@pytest.fixture
def huey_immediate_mode(settings):
	settings.HUEY["immediate"] = True
```

... however dropping a `breakpoint` into a test shows that the `huey` tasks still think they are in `immediate = False` mode.  This holds even if the `tasks` module is imported after calling the fixture.

So I monkeypatched all tasks `huey` to force `immediate = True`  ...

```python
import huey
import pytest


@pytest.fixture
def huey_immediate_mode(monkeypatch):

    from stationmanager import tasks

    _tasks = [

        obj

        for obj in tasks.__dict__.values()

        if isinstance(obj, huey.api.TaskWrapper)

    ]

    for t in _tasks:

        monkeypatch.setattr(t.huey, "immediate", True)
```

... and success!  All tasks now run immediately!

#django
#huey
#pytest