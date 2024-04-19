I can use `nix profile` as a `Postgres` package manager & install `Postgres` globally with `TimescaleDB` ...

```sh
nix profile install --impure --expr 'with import <nixpkgs> {}; pkgs.postgresql.withPackages   (p: [ p.timescaledb ])'
```

#nix