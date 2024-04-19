**TL;DR;** I can just use a `nix` expression with `nix profile` ...

```sh
nix profile install --impure --expr 'with import <nixpkgs> {}; pkgs.postgresql.withPackages (p: [ p.timescaledb ])' 
```

---


I want to install `timescaledb` via [`nix`](https://github.com/DeterminateSystems/nix-installer) ...

```sh
nix profile install nixpkgs#postgresql
nix profile install nixpkgs#timescaledb
```

... create the database storage area ... 

```sh
pg_ctl init -D .db/
```

... launch a database server ...

```sh
pg_ctl start -D .db/
```

... create a database ...

```sh
createdb db
```

... connect to the database ...

```sh
psql -d db
```

... & install `timescaledb`  ...

```sql
create extension timescaledb
```

... **but** I can't!

`create extension` fails with ...

```sql
ERROR:  could not access file "$libdir/timescaledb-2.13.0": No such file or directory
```

Why?

On running `create extension`, `Postgres` searches `SHARDIR/postgresql/extension/` for a corresponding `control` file like `<extension-name>.control`.  Each file specifies `module_path` which links to extension binaries.

By default,  the builtin extensions are automatically available, but 3rd party extensions are not.

On running `nix profile install` for `postgresql` & `timescaledb`, `nix` creates a modifiable directory `~/.nix-profile/share/postgresql/extension` which correctly symlinks `control` files for both builtins & `timescaledb`.

One problem.  As of [`69d61d5/timescaledb.nix`](https://github.com/NixOS/nixpkgs/blob/69d61d5ab0500d9ee52881ebacfb8c8f268ca0d8/pkgs/servers/sql/postgresql/ext/timescaledb.nix), `timescaledb.control` specifies that the `timescaledb` binary is available in `$(libdir)` which I understand is the default `Postgres` extension directory in which `timescaledb` won't be found, hence the error.  To work around this, `timescaledb.control` could instead point to `/nix/store/timescaledb-<X>/lib`.

Could I adapt 

```nix
    for x in src/CMakeLists.txt src/loader/CMakeLists.txt tsl/src/CMakeLists.txt; do
      substituteInPlace "$x" \
        --replace 'DESTINATION ''${PG_PKGLIBDIR}' "DESTINATION \"$out/lib\""
    done
```

... from [`69d61d5/timescaledb.nix`](https://github.com/NixOS/nixpkgs/blob/69d61d5ab0500d9ee52881ebacfb8c8f268ca0d8/pkgs/servers/sql/postgresql/ext/timescaledb.nix) to change this `control` file?

**Or** can I just install `timescaledb` into `Postgres` using `withPackages`?

Yes!

I can just use a `nix` expression with `nix profile` ...

```sh
nix profile install --impure --expr 'with import <nixpkgs> {}; pkgs.postgresql.withPackages (p: [ p.timescaledb ])' 
```

... one step further but now I'm blocked with ...

```
SQL Error [XX000]: FATAL: extension "timescaledb" must be preloaded
  Hint: Please preload the timescaledb library via shared_preload_libraries.

This can be done by editing the config file at: /Users/rowanm/Code/digital_wra_data_standard/.db/postgresql.conf
and adding 'timescaledb' to the list in the shared_preload_libraries config.
	# Modify postgresql.conf:
	shared_preload_libraries = 'timescaledb'

Another way to do this, if not preloading other libraries, is with the command:
	echo "shared_preload_libraries = 'timescaledb'" >> /Users/rowanm/Code/digital_wra_data_standard/.db/postgresql.conf 

(Will require a database restart.)

If you REALLY know what you are doing and would like to load the library without preloading, you can disable this check with: 
	SET timescaledb.allow_install_without_preload = 'on';
```

... which is easy to fix since it just requires adding `shared_preload_libraries = 'timescaledb'` to `postgresql.conf` & restarting `Postgres`,  and now I can `create extension`

#postgres
#nix
#timescaledb
