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

... and now I can `pg_ctl start`

#postgres
