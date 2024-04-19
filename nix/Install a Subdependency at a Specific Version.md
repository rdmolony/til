I wanted to install `Clojure` with `Java` v17 since `NightCode` doesn't work with `Java` v21 due to a deprecated feature called `SecurityManager`

```sh
nix profile install --impure --expr 'with import <nixpkgs> {}; pkgs.clojure.override { jdk = pkgs.jdk17; }'
```

I can do the same for `leiningen` ...

```sh
nix profile install --impure --expr 'with import <nixpkgs> {}; pkgs.leiningen.override { jdk = pkgs.jdk17; }'
```

#nix