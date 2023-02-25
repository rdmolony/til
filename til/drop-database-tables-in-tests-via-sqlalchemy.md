I have a data pipeline that loads text files, enriches them with data from a `Django` `MySQL` database & dumps the enriched data to the same `MySQL` database.

I want to test this pipeline via `pytest`.  I can use `sqlalchemy` to ...

- Connect to the database 
- Inspect it to see what tables it contains
- Drop the tables on test completion

```python
from pathlib import Path
import typing

import fsspec
from numpy import dtype
import pandas as pd
import pytest
import sqlalchemy as sa

from dataimporter import tasks
from stationmanager import models


@pytest.mark.django_db
class TestTidyAndSaveToDb:
    @pytest.fixture
    def uri(self, settings) -> str:
        host = settings.DATABASES.get("default").get("HOST") 
        db_name = settings.DATABASES.get("default").get("NAME") 
        user = settings.DATABASES.get("default").get("USER") 
        password = settings.DATABASES.get("default").get("PASSWORD") 
        return f"mysql+mysqldb://{user}:{password}@{host}/{db_name}"
    
    
    def drop_tables(self, engine, names: typing.List[str]) -> None:
        metadata = sa.MetaData(engine)
        metadata.reflect() # fetches the table metadata from the db
        tables = [
            metadata.tables.get(name)
            for name in names
            if name in metadata.tables.keys()
        ] 
        for table in tables:
            try:
                table.drop()
            except:
                pass        
        
    @pytest.fixture
    def tables(self, uri: str) -> typing.List[str]:
        engine = sa.create_engine(uri)
        table_names = [
            "Battery",
            "Pressure",
            "Relative Humidity",
            "Temperature",
            "Wind Direction",
            "Wind Direction",
            "Wind Speed"
        ]
        yield table_names
        self.drop_tables(engine, table_names)
```

Calling the `tables` fixture in any `pytest` test will yield the table names - these tables are generated from dummy data used for the test run - & will then drop them on completion

#sqlalchemy
#pytest
#django