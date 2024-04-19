In the past I've used `Docker Compose` & `devenv.sh` to launch `Postgres` for me

This time I installed it via `nix` ...

```sh
nix profile install nixpkgs#postgresql
```

... so I have to start it myself via `pg_ctl start`

To use `Postgres` I need to first create a database,  I can specify where it is via environment variable `PGDATA` ...

```sh
export PGDATA=~/Postgres
pg_ctl init
```

... and now I can ... 

... start the database server via ...

```sh
pg_ctl start
```

... create a database via ...

```sh
createdb db
```

... and connect to it via ...

```sh
psql -d db
```

... or via `DBeaver`

> Note that `pg_ctl init` automatically creates a role with the same name as my `MacOS` account!

#postgres
