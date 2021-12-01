# How to monkeypatch a database connection

I want to test that a method `Datasource.fetch_dataframe` raises a VPN connection error
if the user is connected to `StationManager` but is not connected to a VPN.  I'm not
interested in connecting to a database, only in how this method reacts to a database 
connection error `pyodbc.OperationalError`.

I tried using `mock.MagicMock` to replace `pyodbc` with a magic object that does nothing
but return `pyodbc.OperationalError` when `pyodbc.connect` is called so that the
database connection error is raised every time the test is run ...

```python
from unittest.mock import MagicMock

import pyodbc
from _pytest.monkeypatch import MonkeyPatch

from stationmanager.models import Datasource


def test_fetch_dataframe_raises_vpn_error(monkeypatch: MonkeyPatch) -> None:
    # ... other setup ...
    monkeypatch.setattr(
        pyodbc, "connect", MagicMock(return_value=pyodbc.OperationalError)
    )

    datasource = Datasource()

    with pytest.raises(pyodbc.OperationalError):
        datasource.fetch_dataframe(raw_db_table=True)

```

... however this merely returns the `pyodbc.OperationalError` and does not raise an
error.  It must instead be raised explicitely ...

```python
def test_fetch_dataframe_raises_vpn_error(monkeypatch: MonkeyPatch) -> None:
    def _mock_pyodbc_connect(*args, **kwargs) -> None:
        raise pyodbc.OperationalError

    # ... other setup ...
    monkeypatch.setattr(pyodbc, "connect", _mock_pyodbc_connect)

    datasource = Datasource()

    with pytest.raises(pyodbc.OperationalError):
        datasource.fetch_dataframe(raw_db_table=True)

```