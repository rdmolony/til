# Restore a mysql database on docker compose

This one was tough.  I had a `Docker Compose` `yml` of ...

```yml
version: "3.7"

services:
  db:
    image: mysql
    volumes:
      - ./db:/var/lib/mysql
      - ./backups/datadump.sql:/docker-entrypoint-initdb.d/datadump.sql
    environment:
      - MYSQL_DATABASE=$MYSQL_NAME
      - MYSQL_USER=$MYSQL_USER
      - MYSQL_PASSWORD=$MYSQL_PASSWORD
      - MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
  ...
  web:
    build: .
    command: python manage.py runserver 0.0.0.0:8000
    volumes:
      - .:/app
    ports:
      - "8000:8000"
    depends_on:
      - db
```

... and couldn't work out how to alter the database permissions so that I could access the database from a host other than the `db` localhost.  Specifically, I kept running into user `'username'@'IP'` cannot access `'databasename'` when launching `Docker Compose`.

From the [`MySQL` `Docker`](https://github.com/docker-library/docs/tree/master/mysql) docs (and `Stackoverflow` and `Docker Community`...) I found that setting the environment variable `MYSQL_ROOT_HOST` to `%` enables accessing the database from a any IP address.  After much pain I found out (by reading the `Shell` script `docker-entrypoint.sh` for this container) that `MYSQL_ROOT_HOST` is automatically set to `%`!  This meant that the `datadump.sql` file being run to restore the database overwrites user permissions!  A quick scan of the `sql` file validated this!

Now how do I overwrite the overwrite!?  The bloody [`MySQL` docs](https://dev.mysql.com/doc/refman/8.0/en/resetting-permissions.html) have the answer!  I just needed to ...

... run `mysqld --skip-grant-tables` to enable connecting to the server without a password and with all privileges ... 

```bash
...
      - MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
    command: --skip-grant-tables
...
```

... launch the database ...

```bash
docker compose up db
```

... hook into the running database server ...

```bash
docker exec -it stationmanager-db-1 mysql
```

... tell the server to reload the grant tables so that account-management statements work ..
```sql
FLUSH PRIVILEGES;
```

... add the user permissions needed to access the database ...

```sql
ALTER USER 'username'@'%' IDENTIFIED BY 'MyNewPass';
GRANT ALL ON *.* TO 'username'@'%' WITH GRANT OPTION ;
```

... and finally the `Docker` `web` container can now connect to the `db` server which is running our restored database!

#docker