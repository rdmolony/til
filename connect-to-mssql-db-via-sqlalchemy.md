# Connect to mssql db

I want to upload csv data to a `Microsoft SQL Server` (`mssql`) database.  I can use `pandas` to read & wrangle the csv data and `sqlalchemy` and `pyodbc` to upload it.

To authenticate my flow I can pass in my credentials using a `config` dict loaded from a `.env` file (or `prefect` secrets) ... 

```python
import sqlalchemy as sa

connection_string = (
    "mssql+pyodbc://"
    f"{config['MSSQL_USER']}:{config['MSSQL_PASSWORD']}"
    f"@{config['MSSQL_HOST']}:{config['MSSQL_PORT']}"
    f"/{db_name}"
    f"?driver={config['MSSQL_DRIVER']}"
)
engine = sa.create_engine(connection_string)
table_name = "my_table"
df.to_sql(name=table_name, con=engine, if_exists="append")
```

... where MSSQL_USER has the necessary permissions to create a new table if necessary.  

I can set these permissions using SQL Server Management Studio (SSMS) by:

1. Adding a new user to `Security > Logins` with:

    - **User Mapping** - add *db_datareader*, *db_datawriter*, *db_ddladmin*
    - **Securables** - add server *SERVER_NAME*

2. Vefifying user permissions on database via `Databases > DATABASE_NAME > Properties > Permissions > Effective`

#sql
