I wanted to try out `devenv` as an alternative to `Docker Compose`.  `devenv` uses `nix` to manage developer environments in place of containers.

I typically use `poetry` to manage `Python` dependencies & luckily there's a `nix` integration for it:  https://github.com/nix-community/poetry2nix

I'm new to `nix` so working out how to combine these two `nix` tools is a challenge.  Both tools provide `nix` flake examples.

[`poetry2nix`](https://github.com/nix-community/poetry2nix) ...

```nix
 930 Bytes

{
  description = "Application packaged using poetry2nix";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.poetry2nix = {
    url = "github:nix-community/poetry2nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # see https://github.com/nix-community/poetry2nix/tree/master#api for more functions and examples.
        inherit (poetry2nix.legacyPackages.${system}) mkPoetryApplication;
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          myapp = mkPoetryApplication { projectDir = self; };
          default = self.packages.${system}.myapp;
        };

        devShells.default = pkgs.mkShell {
          packages = [ poetry2nix.packages.${system}.poetry ];
        };
      });
}
```

[`devenv`](https://github.com/cachix/devenv/blob/c53c30b524fecdadd66b29c85e588cce47d2cb3e/templates/simple/flake.nix)

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    devenv.url = "github:cachix/devenv";
  };

  outputs = { self, nixpkgs, devenv, ... } @ inputs:
    let
      systems = [ "x86_64-linux" "i686-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = f: builtins.listToAttrs (map (name: { inherit name; value = f name; }) systems);
    in
    {
      devShells = forAllSystems
        (system:
          let
            pkgs = import nixpkgs {
              inherit system;
            };
          in
          {
            default = devenv.lib.mkShell {
              inherit inputs pkgs;
              modules = [
                {
                  # https://devenv.sh/reference/options/
                  packages = [ pkgs.hello ];

                  enterShell = ''
                    hello
                  '';
                }
              ];
            };
          });
    };
}
```

Combining the two we get ...

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    devenv.url = "github:cachix/devenv";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, devenv, poetry2nix, ... } @ inputs:
    let
      systems = [ "x86_64-linux" "i686-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = f: builtins.listToAttrs (map (name: { inherit name; value = f name; }) systems);
    in
    {
      devShells = forAllSystems
        (system:
          let
            inherit (poetry2nix.legacyPackages.${system}) mkPoetryApplication;
            pkgs = nixpkgs.legacyPackages.${system};
          in
          {
            packages = {
              myapp = mkPoetryApplication { projectDir = self; };
              default = self.packages.${system}.myapp;
            };
            default = devenv.lib.mkShell {
              inherit inputs pkgs;
              modules = [
                {
                  # https://devenv.sh/reference/options/
                  packages = [pkgs.hello poetry2nix.packages.${system}.poetry ];

                  enterShell = ''
                    hello
                  '';
                }
              ];
            };
          });
    };
}
```

#nix
#devenv
#poetry2nix
