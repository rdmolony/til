Similarly to ...

- [[Install a Subdependency at a Specific Version]]
- [[Install PosgreSQL Globally with Extensions]]

... I can install `Python` with `pipx` via ...

```sh
nix profile install --impure --expr 'with import <nixpkgs> {}; pkgs.python39.withPackages (pip: [pip.pipx])'
```

... as per https://nixos.wiki/wiki/Python

#nix